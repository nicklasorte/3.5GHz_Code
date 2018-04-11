function func_agg_check(app,rand_pts,single_search_dist,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,mc_size,tf_sector)

disp_progress(app,strcat('Calculating the Aggregate Checks . . . '))
            [x22,~]=size(rand_pts);
            if parallel_flag==1
                disp_progress(app,strcat('Calculating the ParFor Aggregate Checks . . . '))
                [hWaitbar,hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Agg Check: ',x22); % Create ParFor Waitbar
                parfor point_idx=1:1:x22
                    parfor_wrapper_agg_check_rev5_no_sub_folder_sector(app,single_search_dist,point_idx,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,mc_size,tf_sector)
                    hWaitbarMsgQueue.send(0);
                end
                delete(hWaitbarMsgQueue);
                close(hWaitbar);
            end
            if parallel_flag==0
                disp_progress(app,strcat('Calculating the ForLoop Aggregate Checks . . . '))
                parfor_progress_time(app,x22);
                for point_idx=1:1:x22
                    parfor_wrapper_agg_check_rev5_no_sub_folder_sector(app,single_search_dist,point_idx,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,cbsd_deployment_percent,mc_size,tf_sector)
                    parfor_progress_time(app);
                end
                parfor_progress_time(app,0);
            end
            
end