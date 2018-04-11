function parfor_wrapper_agg_check_rev5_no_sub_folder_sector(app,search_dist_array,point_idx,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,mc_size,tf_sector)

%%%%%%%%We will check for the move list before loading the Pr_dBm
[tf_calc]=check_agg_check_no_sub_folder(app,search_dist_array,parallel_flag,point_idx,sim_number,cbsd_deployment_percent,mc_size);

if tf_calc==1
    sim_pt=rand_pts(point_idx,:);
    
    %%%%%%Check/Calculate path loss: CatB
    [CatB_Pr_dBm]=wrapper_CatB_Pr_dBm(app,point_idx,sim_number,full_list_cbsd_catb,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag);
    
    %%%%%%%%Check/Calculate path loss: CatA
    [CatA_Pr_dBm]=wrapper_CatA_Pr_dBm(app,point_idx,sim_number,full_list_cbsd_cata,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss);
    
    x23=length(search_dist_array);
    for dist_idx=1:1:x23
        union_master_turn_off_idx=NaN(1);
        search_dist=search_dist_array(dist_idx);
        
        %%%%%%%%%%Load union_master_turn_off_idx for the distance
        file_name2=strcat('union_master_turn_off_idx_',num2str(cbsd_deployment_percent),'_',num2str(search_dist),'.mat');
        
        %%%%%%Check for existence, if file_name2 does not exist, skip
        [union_exist]=persistent_var_exist(app,file_name2);
        
        if union_exist==2
            retry_load=1;
            while(retry_load==1)
                try
                    load(file_name2,'union_master_turn_off_idx')
                    retry_load=0;
                catch
                    retry_load=1;
                    pause(0.1)
                end
            end
            
            %%%%%%%%%Need to eliminate NaNs
            union_master_turn_off_idx=union_master_turn_off_idx(~isnan(union_master_turn_off_idx));
            
            if all(isnan(union_master_turn_off_idx))==1
                if parallel_flag==0
                    disp_progress(app,strcat('union_master_turn_off_idx is NAN <-- Wait and Reload'))
                end
                pause(1);
            else  %%%%%%It is not NaN and we will calculate the aggregate
                %%%%%%%%%Check for Move List File, if none, save place holder
                file_name3=strcat('max_agg_dBm95_',num2str(point_idx),'_',num2str(sim_number),'_',num2str(cbsd_deployment_percent),'_',num2str(search_dist),'_',num2str(mc_size),'.mat');
                [var_exist]=persistent_var_exist(app,file_name3);
                
                if var_exist==0 %%%%%%%%%Run the Simulation
                    %%%%%%Save a NaN file as a placeholder so that others don't work on this iteration
                    max_agg_dBm95=NaN(1);
                    
                    %%%%%%Persistent Save
                    retry_save=1;
                    while(retry_save==1)
                        try
                            %save(file_name3,'max_agg_dBm95')
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(1)
                        end
                    end
                                        
                    
                    %%%%This is where we limit the number of CBSDs to a percentage
                    [x80,~]=size(full_list_cbsd_catb);
                    keep_catb=1:1:ceil((x80*(cbsd_deployment_percent/100)));
                    
                    [x81,~]=size(full_list_cbsd_cata);
                    keep_cata=1:1:ceil((x81*(cbsd_deployment_percent/100)));
                    
                    temp_CatA_Pr_dBm=CatA_Pr_dBm(keep_cata',:);
                    temp_CatB_Pr_dBm=CatB_Pr_dBm(keep_catb',:);
                    
                    if tf_sector==1
                        %%%%Keep the Azimuths
                        list_cbsd_catb=full_list_cbsd_catb(keep_catb',:);
                        list_cbsd_cata=full_list_cbsd_cata(keep_cata',:);
                        
                        %%%%%%%%%%%%%%%%%Need to Apply Azimuth Loss to CatB_Pr_dBm
                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%This is where we will do the sector loss
                         [catb_sector_ant_loss,rep_list_catb_azi]=calculate_cbsd_loss_sector(app,list_cbsd_catb,sim_pt);
                        
                        %%%%%%%%%%Split the CatB into 3 CBSDs, each with an azimuth
                        rep_CatB_Pr_dBm=vertcat(temp_CatB_Pr_dBm,temp_CatB_Pr_dBm,temp_CatB_Pr_dBm)+catb_sector_ant_loss;
                                                
                        %%%%%%%%%%%%%%%%%%%%Aggregate Check: Keep CBSD that are on, then feed points into Aggregate Check
                        [list_cata_on,list_catb_on,idx_cata_on,idx_catb_on]=find_on_cbsd_agg_check_with_idx(app,list_cbsd_cata,rep_list_catb_azi,union_master_turn_off_idx);
                      
                        temp_list_on=vertcat(list_cata_on,list_catb_on);
                        temp_on_Pr_dBm=vertcat(temp_CatA_Pr_dBm(idx_cata_on,:),rep_CatB_Pr_dBm(idx_catb_on,:));
                        
                    else
                        %%%%Originally Cut the Azimuths
                        list_cbsd_catb=full_list_cbsd_catb(keep_catb',1:5);
                        list_cbsd_cata=full_list_cbsd_cata(keep_cata',1:5);
                  
                        %%%%%%%%%%%%%%%%%%%%Aggregate Check: Keep CBSD that are on, then feed points into Aggregate Check
                        [list_cata_on,list_catb_on,idx_cata_on,idx_catb_on]=find_on_cbsd_agg_check_with_idx(app,list_cbsd_cata,list_cbsd_catb,union_master_turn_off_idx);
                    
                        temp_list_on=vertcat(list_cata_on,list_catb_on);
                        temp_on_Pr_dBm=vertcat(temp_CatA_Pr_dBm(idx_cata_on,:),temp_CatB_Pr_dBm(idx_catb_on,:));
                     end
                    
                    %%%%%%%%%%%%Calculate Aggregate with all CBSDs
                    [rand_seed2]=rand_seed2_generator(app,search_dist,point_idx,mc_size); %Point_idx and turn_off size starts as the seed to the rand seed
                    
                    %%%%%%%Step3: Calculate Each CBSD Azimuth and the Azimuths to Perform Aggregate Interference Calculation
                    [opt_azimuth_search_idx,cbsd_azimuth]=find_cbsd_count_azi(app,sim_pt,temp_list_on);
                    
                    %%%%%%%%%%%%%%Step 6: Generate MC Iterations and Aggregate Calculation
                    mc_count_chunk=1:1:mc_size;
                    [cell_agg_check]=sub_function_aggcheck_parfor_slimmer(app,mc_count_chunk,rand_seed2,reliability,temp_on_Pr_dBm,opt_azimuth_search_idx,cbsd_azimuth);
                    array_agg_check=cell2mat(cell_agg_check');
                    
%                     figure;
%                     hold on;
%                     plot(array_agg_check)
                    
                    azi_agg_dBm95=NaN(length(opt_azimuth_search_idx),1);
                    for i=1:1:length(opt_azimuth_search_idx)
                        azi_agg_dBm95(i)=nick_percentile(app,array_agg_check(i,:),95);
                    end
                    max_agg_dBm95=max(azi_agg_dBm95);
                    
                    %%%%%%%%Save Aggregate: max_agg_dBm95, Persistent Save
                    retry_save=1;
                    while(retry_save==1)
                        try
                            save(file_name3,'max_agg_dBm95')
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(1)
                        end
                    end
                end
            end
        end
    end
    
end