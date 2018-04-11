function func_calc_path_loss(app,rand_pts,parallel_flag,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,building_loss)

% %%%%%%%%%%%%%%Calculate Path Loss
[x22,~]=size(rand_pts);
if parallel_flag==1
    disp_progress(app,strcat('Starting the Parfor Calculate Path Loss'))
    [hWaitbar,hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Path Loss: ',x22);    %%%%%%% Create ParFor Waitbar
    parfor point_idx=1:1:x22
        %%%%%%%%%%%%%%%File Check Before Parfor wrapper, reducing overhead
        parfor_wrapper_calc_pathloss_no_sub_folder(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,point_idx)
        hWaitbarMsgQueue.send(0);
    end
    delete(hWaitbarMsgQueue);
    close(hWaitbar);
end
if parallel_flag==0
    disp_progress(app,strcat('Starting the ForLoop Calculate Path Loss'))
    parfor_progress_time(app,x22);
    for point_idx=1:1:x22
        %%%%%%%%%%%%%%%File Check Before Parfor wrapper, reducing overhead
        parfor_wrapper_calc_pathloss_no_sub_folder(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,point_idx)
        parfor_progress_time(app);
    end
    parfor_progress_time(app,0);
end

end