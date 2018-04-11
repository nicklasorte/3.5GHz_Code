function wrapper_move_union_agg_scrap_rev5(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,mc_size,radar_threshold,single_search_dist,catb_neighborhood,data_label1,tf_sector,tf_search_main_beam)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate Move List
        %%%%%%%Check for existence of move list for a single distance
        [tf_calc_move]=check_move_list_single_dist(app,rand_pts,parallel_flag,sim_number,cbsd_deployment_percent,single_search_dist);
        if tf_calc_move==1
            %%%%%%%%%%%%%%Calculate Move List
            %func_calc_move_list_sector_option(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,mc_size,radar_threshold,single_search_dist,catb_neighborhood,tf_sector)
            func_calc_move_list_sector_mainbeam_option_rev2(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,cata_neighborhood,mc_size,radar_threshold,single_search_dist,catb_neighborhood,tf_sector,tf_search_main_beam)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Create Union Move List
        %%%%%Check for union move list is inside
        parfor_wrapper_union_move_list_no_sub_folder(app,single_search_dist,1,cbsd_deployment_percent,rand_pts,sim_number,parallel_flag)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate Aggregate Check
        %%%%Check for Aggregate Check Files
        [tf_calc_agg]=check_agg_check_single_dist(app,rand_pts,parallel_flag,sim_number,cbsd_deployment_percent,single_search_dist,mc_size);
        %%%%%%Calculate Aggregate
        if tf_calc_agg==1
            func_agg_check(app,rand_pts,single_search_dist,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,mc_size,tf_sector)

            
%             disp_progress(app,strcat('Calculating the Aggregate Checks . . . '))
%             [x22,~]=size(rand_pts);
%             if parallel_flag==1
%                 disp_progress(app,strcat('Calculating the ParFor Aggregate Checks . . . '))
%                 [hWaitbar,hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Agg Check: ',x22); % Create ParFor Waitbar
%                 parfor point_idx=1:1:x22
%                     parfor_wrapper_agg_check_rev5_no_sub_folder_sector(app,single_search_dist,point_idx,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,mc_size,tf_sector)
%                     hWaitbarMsgQueue.send(0);
%                 end
%                 delete(hWaitbarMsgQueue);
%                 close(hWaitbar);
%             end
%             if parallel_flag==0
%                 disp_progress(app,strcat('Calculating the ForLoop Aggregate Checks . . . '))
%                 parfor_progress_time(app,x22);
%                 for point_idx=1:1:x22
%                     parfor_wrapper_agg_check_rev5_no_sub_folder_sector(app,single_search_dist,point_idx,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,mc_size,tf_sector)
%                     parfor_progress_time(app);
%                 end
%                 parfor_progress_time(app,0);
%             end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Scrap Aggregate Data for Single Distance
        scrap_data_single_dist(app,rand_pts,sim_number,cbsd_deployment_percent,single_search_dist,mc_size,data_label1)

end