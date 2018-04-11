function parfor_wrapper_move_list_rev8_no_sub_folder_mainbeamsector_rev3(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,point_idx,mc_size,radar_threshold,search_dist_array,catb_neighborhood,tf_sector,tf_search_main_beam)

    %%%%%%%%We will check for the move list before loading the Pr_dBm
    [tf_calc]=check_move_list_no_sub_folder(app,search_dist_array,parallel_flag,point_idx,sim_number,cbsd_deployment_percent);

    if tf_calc==1
        sim_pt=rand_pts(point_idx,:);
        
        %%%%%%Check/Calculate path loss: CatB --> Very Slow Because of Larger Distances
        [CatB_Pr_dBm]=wrapper_CatB_Pr_dBm(app,point_idx,sim_number,full_list_cbsd_catb,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag);

        %%%%%%%%Check/Calculate path loss: CatA ---> Fast Because of Smaller Distances
        [CatA_Pr_dBm]=wrapper_CatA_Pr_dBm(app,point_idx,sim_number,full_list_cbsd_cata,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss);

        x23=length(search_dist_array);
        for dist_idx=1:1:x23
            search_dist=search_dist_array(dist_idx);
            
            %%%%%%%%%Check for Move List File, if none, save place holder
            file_name=strcat('master_turn_off_idx_',num2str(point_idx),'_',num2str(sim_number),'_',num2str(cbsd_deployment_percent),'_',num2str(search_dist),'.mat');
            [var_exist]=persistent_var_exist(app,file_name);
            
            if var_exist==0 %%%%%%%%%Run the Simulation
                %%%%%%Save a NaN file as a placeholder so that others don't work on this iteration
                
                %%%%%%%%%%%%%We only need this here if we have multiple servers working on the same sim.
                master_turn_off_idx=NaN(1);

                %%%%%%Persistent Save
                retry_save=1;
                while(retry_save==1)
                    try
                        %save(file_name,'master_turn_off_idx')
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

                %%%%%%%%%%%%%%%%%%Find the Move List for the distance
                if tf_sector==1
                    %%%%Keep the Azimuths
                    list_cbsd_catb=full_list_cbsd_catb(keep_catb',:);
                    list_cbsd_cata=full_list_cbsd_cata(keep_cata',:);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%This is where we will do the sector loss
                    [catb_sector_ant_loss,rep_list_catb_azi]=calculate_cbsd_loss_sector(app,list_cbsd_catb,sim_pt);
                    all_cbsds=vertcat(list_cbsd_cata,rep_list_catb_azi);
                  
                    %%%%%%%%%It can't find the CatA CBSDs because of the NAN Azimuth
                    
                    %%%%%%%%From Here we will cut based on distance and CBSD antenna loss
                    idx_mainbeam=find(catb_sector_ant_loss>-20);  %%%Find those at -20 or greater than
                    idx_neg20=find(catb_sector_ant_loss==-20);
                    
                    list_catb_mainbeam=rep_list_catb_azi(idx_mainbeam,:);
                    list_catb_neg20=rep_list_catb_azi(idx_neg20,:);
                    
                    rep_CatB_Pr_dBm=vertcat(CatB_Pr_dBm,CatB_Pr_dBm,CatB_Pr_dBm);
                    CatB_Pr_dBm_mainbeam=rep_CatB_Pr_dBm(idx_mainbeam,:)+catb_sector_ant_loss(idx_mainbeam);
                    CatB_Pr_dBm_neg20=rep_CatB_Pr_dBm(idx_neg20,:)+catb_sector_ant_loss(idx_neg20);
                    
                    [temp_cata_list,cata_idx_inside]=create_temp_list(app,list_cbsd_cata,sim_pt,cata_neighborhood);
                    if tf_search_main_beam==1 %%%%%%%%%%%%Search the Main Beam
                        [temp_catb_mb_list,catb_mb_idx_inside]=create_temp_list(app,list_catb_mainbeam,sim_pt,search_dist);
                        [temp_catb_neg20_list,catb_neg20_idx_inside]=create_temp_list(app,list_catb_neg20,sim_pt,catb_neighborhood);
                    else %%%%%%%%%Search the side lobes
                        [temp_catb_mb_list,catb_mb_idx_inside]=create_temp_list(app,list_catb_mainbeam,sim_pt,catb_neighborhood);
                        [temp_catb_neg20_list,catb_neg20_idx_inside]=create_temp_list(app,list_catb_neg20,sim_pt,search_dist);
                    end
                    
                    %%%%%%%%%%%%%Fix the Empty Array Problem
                    temp_list=vertcat(temp_cata_list,temp_catb_mb_list,temp_catb_neg20_list); 
                    temp_list=temp_list(~isnan(temp_list(:,1)),:);
                    temp_Pr_dBm=vertcat(CatA_Pr_dBm(cata_idx_inside,:),CatB_Pr_dBm_mainbeam(catb_mb_idx_inside,:),CatB_Pr_dBm_neg20(catb_neg20_idx_inside,:));
                    
                else
                    %%%%Originally Cut the Azimuths
                    list_cbsd_catb=full_list_cbsd_catb(keep_catb',1:5);
                    list_cbsd_cata=full_list_cbsd_cata(keep_cata',1:5);
                    all_cbsds=vertcat(list_cbsd_cata,list_cbsd_catb);
                    
                    [temp_catb_list,catb_idx_inside]=create_temp_list(app,list_cbsd_catb,sim_pt,search_dist); %%%%%%%%The CatB Neighborhood is being searched
                    [temp_cata_list,cata_idx_inside]=create_temp_list(app,list_cbsd_cata,sim_pt,cata_neighborhood);
                    
                    temp_list=vertcat(temp_cata_list,temp_catb_list);
                    temp_list=temp_list(~isnan(temp_list(:,1)),:);
                    temp_Pr_dBm=vertcat(CatA_Pr_dBm(cata_idx_inside,:),CatB_Pr_dBm(catb_idx_inside,:));
                end

                %%%%%%%%Rand Seed1 for MC Iterations and Move List Calculation
                [rand_seed1]=rand_seed1_generator(app,search_dist,cata_neighborhood,point_idx,mc_size);
                
                if all(isempty(temp_Pr_dBm))==1
                    master_turn_off_idx=NaN(1);
                else
                    [sort_pr_idx]=create_sorted_movelist(app,temp_Pr_dBm,reliability);

                    %%%%%%%Step6: Calculate Each CBSD Azimuth and the Azimuths to Perform Move List Calculation
                    [opt_azimuth_search_idx,cbsd_azimuth]=find_cbsd_count_azi(app,sim_pt,temp_list);
                    
                    %%%%%%%%%%%%%%Step 6: Generate MC Iterations and Calculate Move List
                    mc_count_chunk=1:1:mc_size;
                    %cell_turn_off_size=sub_function_movelist_parfor_slimmer(app,mc_count_chunk,rand_seed1,reliability,temp_Pr_dBm,radar_threshold,sort_pr_idx,opt_azimuth_search_idx,cbsd_azimuth);
                    [cell_turn_off_size,cell_agg_azi]=sub_function_movelist_agg_out(app,mc_count_chunk,rand_seed1,reliability,temp_Pr_dBm,radar_threshold,sort_pr_idx,opt_azimuth_search_idx,cbsd_azimuth);

                    array_agg_azi=cell2mat(cell_agg_azi');
                    %max(max(array_agg_azi))
                    if max(max(array_agg_azi))>radar_threshold
                        if parallel_flag==0
                            disp_progress(app,strcat('master_turn_off_idx is greater than size of CBSD list-- IDX:',num2str(point_idx),' Distance:',num2str(search_dist)))
                        end
                        placeholder=NaN(1);
                        save(stract('ERROR_move_list_agg_greater_point_idx',num2str(point_idx),'_dist',num2str(search_dist),'.mat'),'placeholder')
                    end
                    array_turn_off_size=cell2mat(cell_turn_off_size');
                    
                    azi_turnoff=NaN(length(opt_azimuth_search_idx),1);
                    for i=1:1:length(opt_azimuth_search_idx)
                        azi_turnoff(i)=nick_percentile(app,array_turn_off_size(i,:),95);
                    end
                    turn_off_size95=max(azi_turnoff);
                    
                    if isempty(turn_off_size95)==1
                        turn_off_size95=0;
                    end
                                        
                    %%%%Need to back calculate temp_list turnoff and map to all_list_turnoff
                    turn_off_idx=sort_pr_idx(1:turn_off_size95);
                    
                    %%%%Need to create  master_turn_off_idx  from turn_off_idx
                    turn_off_cbsd_list=temp_list(turn_off_idx,:);
                    [~,~,master_turn_off_idx]=intersect(turn_off_cbsd_list,all_cbsds,'rows'); %%%%%%%%%This is where the error is occuring
                    
                    [x1,~]=size(all_cbsds);
                    if max(master_turn_off_idx)>x1
                        if parallel_flag==0
                            disp_progress(app,strcat('master_turn_off_idx is greater than size of CBSD list-- IDX:',num2str(point_idx),' Distance:',num2str(search_dist)))
                        end
                        placeholder=NaN(1);
                        save(stract('ERROR_master_turn_off_idx_is_out_of_bounds_point_idx',num2str(point_idx),'_dist',num2str(search_dist),'.mat'),'placeholder')
                    end
                end
                    
                master_turn_off_idx=master_turn_off_idx(~isnan(master_turn_off_idx)); %%%%%This will save the NaN as an empty
                
                
                if max(master_turn_off_idx)>x1
                    %%%%%%%%For Some Reason, the idx are too large
                else %%%%%%It will not save the move list if it is larger than the length of the cbsds
                    %%%%%Save master_turn_off_idx, Persistent Save
                    retry_save=1;
                    while(retry_save==1)
                        try
                            save(file_name,'master_turn_off_idx')
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(1)
                        end
                    end
                end
                               
                if isempty(master_turn_off_idx)==1
                    if parallel_flag==0
                        disp_progress(app,strcat('master_turn_off_idx is EMPTY'))
                    end
                end
                if all(isnan(master_turn_off_idx))==1
                    if parallel_flag==0
                        disp_progress(app,strcat('master_turn_off_idx is NAN'))
                    end
                end
                
            end
        end
    end
end