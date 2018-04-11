function func_calc_move_list_sector_mainbeam_option_rev2(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,mc_size,radar_threshold,single_search_dist,catb_neighborhood,tf_sector,tf_search_main_beam)

%sim_folder=NaN(1);
%%%%%%%%%%%%%%Calculate Move List
            [x22,~]=size(rand_pts);
            if parallel_flag==1
                disp_progress(app,strcat('Starting the Parfor Move List'))
                [hWaitbar,hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Move List: ',x22);    %%%%%%% Create ParFor Waitbar
                parfor point_idx=1:1:x22
                    %%%%%%%%%%%%%%%File Check Before Parfor wrapper, reducing overhead
                    parfor_wrapper_move_list_rev8_no_sub_folder_mainbeamsector_rev3(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,point_idx,mc_size,radar_threshold,single_search_dist,catb_neighborhood,tf_sector,tf_search_main_beam)
                    %parfor_wrapper_move_list_rev7_no_sub_folder_sector_rev2(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,point_idx,mc_size,radar_threshold,single_search_dist,catb_neighborhood,tf_sector)
                    %parfor_wrapper_move_list_rev5_no_sub_folder_sector_debug(app,rand_pts,sim_folder,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,point_idx,mc_size,radar_threshold,single_search_dist,catb_neighborhood,tf_sector);
                    hWaitbarMsgQueue.send(0);
                end
                delete(hWaitbarMsgQueue);
                close(hWaitbar);
            end
            if parallel_flag==0
                disp_progress(app,strcat('Starting the ForLoop Move List'))
                parfor_progress_time(app,x22);
                for point_idx=1:1:x22
                    %%%%%%%%%%%%%%%File Check Before Parfor wrapper, reducing overhead
                    parfor_wrapper_move_list_rev8_no_sub_folder_mainbeamsector_rev3(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,point_idx,mc_size,radar_threshold,single_search_dist,catb_neighborhood,tf_sector,tf_search_main_beam)
                    %parfor_wrapper_move_list_rev7_no_sub_folder_sector_rev2(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,point_idx,mc_size,radar_threshold,single_search_dist,catb_neighborhood,tf_sector)
                    %parfor_wrapper_move_list_rev5_no_sub_folder_sector_debug(app,rand_pts,sim_folder,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,point_idx,mc_size,radar_threshold,single_search_dist,catb_neighborhood,tf_sector);
                    parfor_progress_time(app);
                end
                parfor_progress_time(app,0);
            end
            
end