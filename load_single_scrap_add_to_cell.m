function [all_data_stats_binary]=load_single_scrap_add_to_cell(app,all_data_stats_binary,data_label1,sim_number,single_search_dist)

%%%%%%%Load single scrap and add it to the cell and save cell
    file_name5=strcat(data_label1,'_',num2str(sim_number),'_single_scrap_data_',num2str(single_search_dist),'.mat');
    [var_exist1]=persistent_var_exist(app,file_name5); %%%%%Check for Existence and then load
    if var_exist1==2
        retry_load=1;
        while(retry_load==1)
            try
                load(file_name5,'single_scrap_data')
                retry_load=0;
            catch
                retry_load=1;
                pause(0.1)
            end
        end
    end
    %%%%%%%%Distribute single_scrap_data to all_data_stats_binary
    
    %%%%Distance, Aggregate, Move List Size
    for point_idx=1:1:length(all_data_stats_binary)
        temp_data=all_data_stats_binary{point_idx};
        new_temp_data=vertcat(temp_data,horzcat(single_search_dist,single_scrap_data(point_idx,:)));
        
        %%%%Sort the Data
        [check_sort,sort_idx]=sort(new_temp_data(:,1)); %%%%%%Sorting by Distance just in case
        all_data_stats_binary{point_idx}=new_temp_data(sort_idx,:);
    end
    %%%%%Save the Cell
    file_name_cell=strcat(data_label1,'_',num2str(sim_number),'_all_data_stats_binary.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(file_name_cell,'all_data_stats_binary')
            retry_save=0;
        catch
            retry_save=1;
            pause(0.1)
        end
    end
    
end