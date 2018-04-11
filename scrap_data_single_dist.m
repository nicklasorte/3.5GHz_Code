function scrap_data_single_dist(app,rand_pts,sim_number,cbsd_deployment_percent,single_search_dist,mc_size,data_label1)

    [x22,~]=size(rand_pts);
    single_scrap_data=NaN(x22,2); %%%%Aggregate, Move List Size
    parfor_progress_time(app,x22);
    for point_idx=1:1:x22
        file_name3=strcat('max_agg_dBm95_',num2str(point_idx),'_',num2str(sim_number),'_',num2str(cbsd_deployment_percent),'_',num2str(single_search_dist),'_',num2str(mc_size),'.mat');
        [var_exist3]=persistent_var_exist(app,file_name3); %%%%%Check for Existence and then load
        if var_exist3==2
            max_agg_dBm95=NaN(1);
            retry_load=1;
            while(retry_load==1)
                try
                    load(file_name3,'max_agg_dBm95')
                    retry_load=0;
                catch
                    retry_load=1;
                    pause(0.1)
                end
            end
            if ~isempty(max_agg_dBm95)==1
                single_scrap_data(point_idx,1)=max_agg_dBm95; %%%%%%Aggregate
            end
        end
        
        file_name2=strcat('master_turn_off_idx_',num2str(point_idx),'_',num2str(sim_number),'_',num2str(cbsd_deployment_percent),'_',num2str(single_search_dist),'.mat');
        [var_exist2]=persistent_var_exist(app,file_name2);
        if var_exist2==2
            retry_load=1;
            while(retry_load==1)
                try
                    load(file_name2,'master_turn_off_idx')
                    retry_load=0;
                catch
                    retry_load=1;
                    pause(0.1)
                end
            end
            if ~isempty(master_turn_off_idx)==1
                single_scrap_data(point_idx,2)=length(master_turn_off_idx); %%%%%Length of Move List
            end
        end
        parfor_progress_time(app);
    end
    parfor_progress_time(app,0);
    
    file_name=strcat(data_label1,'_',num2str(sim_number),'_single_scrap_data_',num2str(single_search_dist),'.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(file_name,'single_scrap_data')
            retry_save=0;
        catch
            retry_save=1;
            pause(0.1)
        end
    end
end