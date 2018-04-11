clear;
clc;
close all;
format shortG

app=NaN(1); %%%%%%%%%This is used as a placeholder for when the code in not run in a Matlab Application

folder1='Z:\MATLAB\3.5GHz\Multipoint_Neighborhood\TestGithub';
cd(folder1)
addpath(folder1);
pause(0.1);

%%%%%%%%%%%%Load DPAs
load('mod_dpa_poly_west.mat','mod_dpa_poly_west') %%%West Coast DPAs
load('mod_dpa_poly_east.mat','mod_dpa_poly_east') %%%East Coast DPAs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_label1='JacksonvilleTest'; 
sim_number=11;
dpa_input=mod_dpa_poly_east{2}; %Jacksonville

%%%%%%%%%%%%%%%%%%%


%%%%%%%Create a Sim Folder
cd(folder1);
pause(0.1)
tempfolder=strcat(data_label1,'_Sim',num2str(sim_number));
[status,msg,msgID]=mkdir(tempfolder);
sim_folder=strcat(folder1,'\',tempfolder);
cd(sim_folder)
pause(0.1)

%%%Save DPA Input
save('dpa_input.mat','dpa_input')

%%%%%%%%%Only Generate 1 set of CBSDs, Check for file
 file_name_list=strcat('list_cbsd_cata_azi.mat');
 var_exist_list=exist(file_name_list,'file');
 if var_exist_list==0
     max_catb_dist=515; %%%600
     max_cata_dist=260; %%%%Max is 256 radius
     
     catb_radius=max_catb_dist;
     cata_radius=max_cata_dist;
     rng(sim_number);%For Repeatability
     generate_cbsds_areas_sort_rev2(dpa_input,catb_radius,cata_radius)
 end
 load('list_cbsd_cata_azi.mat','list_cbsd_cata_azi');
 load('list_cbsd_catb_azi.mat','list_cbsd_catb_azi');
 full_list_cbsd_catb=list_cbsd_catb_azi(:,1:8);
 full_list_cbsd_cata=list_cbsd_cata_azi(:,1:6); 
 size(full_list_cbsd_catb)
 size(full_list_cbsd_cata)

%%%%%%%%%%Generate Random Points
number_rand_pts=100;
pt_spacing=10; %%%%%%%%km

%%%%%%%%%Only Generate 1 set of rand points,will check for file
[rand_pts]=generate_3edge_rand_half_edge_spacing(data_label1,sim_number,number_rand_pts,dpa_input,pt_spacing);
[x22,~]=size(rand_pts)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parallel_flag=0; %Enable if you have the Parallel Processing Toolbox, Manually Set to Zero to see progress bar
[poolobj,cores]=start_parpool(app,parallel_flag);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tf_sector=0; %%%If 1, CatB will have 3 sectors, else 0==omni
tf_search_main_beam=0; 
%%%%%%If tf_sector==1, then we will search the mainbeam of CatB if tf_search_main_beam==1 with a fixed off azi distance (CatB Distance)
%%%%%%Else, we will search the off-azi of the CatB with a fixed mainbeam distance
%%%%%%If tf_sector==0, tf_search_main_beam and catb_neighborhood is not taken into consideration

%%%%%%%%%%%%%%%%CBSD Neighborhood Search Parameters
cata_neighborhood=260;
catb_neighborhood=600;
search_dist_array=horzcat(0:16:512); %%%%%%For the Sector or for CatB Omni if tf_sector==0;
%%%%%%%%%%%The binaray search works well with numbers 2^x, 
%%%%%%%%%%%The binaray searhc has not been tested for decimal distances

%%%%%%%%%%%%%%%%%%%Binary Search Parameters
tf_full_binary_search=1; %%%%%%If 0, it will only search for the max point along all protection points
min_binaray_spacing=min(diff(search_dist_array)); %%%%%%%km

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Input Parameters
reliability=[0.1,0.2,0.5,1,2,3,4,5,6,7,8,9,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,91,92,93,94,95,96,97,98,99,99.5,99.8,99.9]';
building_loss=15;
radar_height=50;
Tpol=1; %%%polarization
FreqMHz=3625;
confidence=50;
mc_size=2000;
radar_threshold=-144;
cbsd_deployment_percent=100;
flag_clutter=0;
margin=1; %dB margin for aggregate interference
maine_exception=7100; %%%%Max Move List Size Driven by Palm Bay [Used for an algorithm to determine neighborhood size, specifically the plateu]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%Go to Sim Folder
cd(folder1);
pause(0.1)
tempfolder=strcat(data_label1,'_Sim',num2str(sim_number));
sim_folder=strcat(folder1,'\',tempfolder);
cd(sim_folder)
pause(0.1)


%%%%%%%%%%%%%%%%Calculate Path Loss for all protection point before hand
func_calc_path_loss(app,rand_pts,parallel_flag,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,building_loss)


%%%%%%%Check for all_data_stats_binary, if none, initialize it.
[all_data_stats_binary]=initialize_or_load_all_data_stats_binary(app,data_label1,sim_number,rand_pts);
      
%%%%Step 1: Search Distance MAX
single_search_dist=max(search_dist_array);

    %%%%%Check if that distance is in the all_data_stats_binary
    temp_data=all_data_stats_binary{1};
    if isempty(temp_data)==1 %%%%%%%%Because if this is the first time, it will be empty
        temp_data_dist=NaN(1);
    else
        temp_data_dist=temp_data(:,1);
    end

    if any(temp_data_dist==single_search_dist)==1
        %%%%%%%%Already calculated
    else
        %%%%%%%%Calculate because it is not the right distance
        %%%%%%%%%%%%%%%%%%%%%Wrapper, single distance, move list, union move list, agg check, scrap agg data
        %%%%%%First Check for an array file, named with the single_search_dist and has all the aggregate checks for each protection point.
        file_name=strcat(data_label1,'_',num2str(sim_number),'_single_scrap_data_',num2str(single_search_dist),'.mat');
        [var_exist]=persistent_var_exist(app,file_name);
        if var_exist==0 %%%%%%%%Calculate move list, union, agg check, scrap agg
            wrapper_move_union_agg_scrap_rev5(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,mc_size,radar_threshold,single_search_dist,catb_neighborhood,data_label1,tf_sector,tf_search_main_beam)
        end

        %%%%%%%Load single scrap and add it to the cell and save cell
        [all_data_stats_binary]=load_single_scrap_add_to_cell(app,all_data_stats_binary,data_label1,sim_number,single_search_dist);
    end
        

%%%%Step2: Search Distance MIN
single_search_dist=min(search_dist_array);

    %%%%%Check if that distance is in the all_data_stats_binary
    temp_data=all_data_stats_binary{1};
    temp_data_dist=temp_data(:,1);

    if any(temp_data_dist==single_search_dist)==1
        %%%%%%%%Already calculated
    else
        %%%%%%%%Calculate because it is not the right distance

        %%%%%%%%%%%%%%%%%%%%%Wrapper, single distance, move list, union move list, agg check, scrap agg data
        %%%%%%First Check for an array file, named with the single_search_dist and has all the aggregate checks for each protection point.
        file_name=strcat(data_label1,'_',num2str(sim_number),'_single_scrap_data_',num2str(single_search_dist),'.mat');
        [var_exist]=persistent_var_exist(app,file_name);
        if var_exist==0 %%%%%%%%Calculate move list, union, agg check, scrap agg
            wrapper_move_union_agg_scrap_rev5(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,mc_size,radar_threshold,single_search_dist,catb_neighborhood,data_label1,tf_sector,tf_search_main_beam)
        end

        %%%%%%%Load single scrap and add it to the cell and save cell
        [all_data_stats_binary]=load_single_scrap_add_to_cell(app,all_data_stats_binary,data_label1,sim_number,single_search_dist);
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%Start the Binary Search    
    
%%%%%%%Find the Next Search Dist and if to continue with the all_data_stats_binary
[next_single_search_dist,tf_search,temp_catb_dist_data]=calc_next_search_dist(app,all_data_stats_binary,radar_threshold,margin,maine_exception,tf_full_binary_search,min_binaray_spacing);
    
while(tf_search==1)
    single_search_dist=next_single_search_dist;

    %%%%%Check if that distance is in the all_data_stats_binary
    temp_data=all_data_stats_binary{1};
    temp_data_dist=temp_data(:,1);

    if any(temp_data_dist==single_search_dist)==1
        %%%%%%%%Already calculated
    else
        %%%%%%%%Calculate because it is not the right distance

        %%%%%%%%%%%%%%%%%%%%%Wrapper, single distance, move list, union move list, agg check, scrap agg data
        %%%%%%First Check for an array file, named with the single_search_dist and has all the aggregate checks for each protection point.
        file_name=strcat(data_label1,'_',num2str(sim_number),'_single_scrap_data_',num2str(single_search_dist),'.mat');
        [var_exist]=persistent_var_exist(app,file_name);
        if var_exist==0 %%%%%%%%Calculate move list, union, agg check, scrap agg
            wrapper_move_union_agg_scrap_rev5(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,mc_size,radar_threshold,single_search_dist,catb_neighborhood,data_label1,tf_sector,tf_search_main_beam)
        end

        %%%%%%%Load single scrap and add it to the cell and save cell
        [all_data_stats_binary]=load_single_scrap_add_to_cell(app,all_data_stats_binary,data_label1,sim_number,single_search_dist);
    end
   
            
    %%%%%%%Find the Next Search Dist and if to continue with the all_data_stats_binary
    [next_single_search_dist,tf_search,temp_catb_dist_data,array_searched_dist]=calc_next_search_dist(app,all_data_stats_binary,radar_threshold,margin,maine_exception,tf_full_binary_search,min_binaray_spacing);
    disp_progress(app,strcat('Max CatB Distance:',num2str(max(temp_catb_dist_data))))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Graph the Data
single_mod_plateau_algorithm_rev1(app,data_label1,sim_number,radar_threshold,margin,maine_exception,rand_pts)
close all;




