function [tf_calc]=check_move_list_single_dist(app,rand_pts,parallel_flag,sim_number,cbsd_deployment_percent,single_search_dist)

    [x22,~]=size(rand_pts);
    tf_var_exist_array=NaN(x22,1);
    for point_idx=1:1:x22
%         if parallel_flag==0
%             disp_progress(app,strcat('Point IDX:',num2str(point_idx)))
%         end

        %%%%%%%%%Check for Move List File
        file_name=strcat('master_turn_off_idx_',num2str(point_idx),'_',num2str(sim_number),'_',num2str(cbsd_deployment_percent),'_',num2str(single_search_dist),'.mat');
        [var_exist]=persistent_var_exist(app,file_name);
        
        if var_exist==2
            tf_var_exist_array(point_idx)=0; %%%Already Exists, Do Not Need to Calculate
        else
            tf_var_exist_array(point_idx)=1; %%%Does NOT Exists, Need to Calculate
        end
    end
    if any(tf_var_exist_array)==1
        tf_calc=1; %%%%%Calculate the move list
    else
        tf_calc=0; %%%%%Do Not Calculate the move list
    end
    
end