function [tf_calc]=check_agg_check_no_sub_folder(app,search_dist_array,parallel_flag,point_idx,sim_number,cbsd_deployment_percent,mc_size)


   %%%%%%%%We will check for the move list before loading the Pr_dBm
    x23=length(search_dist_array);
    %%%%%%%Check for existence of move list for all distances
    tf_var_exist_array=NaN(x23,1);
    for dist_idx=1:1:x23
        search_dist=search_dist_array(dist_idx);
%         if parallel_flag==0
%             disp_progress(app,strcat('Search Distance:',num2str(search_dist)))
%         end

        %%%%%%%%%Check for Agg Check
        file_name=strcat('max_agg_dBm95_',num2str(point_idx),'_',num2str(sim_number),'_',num2str(cbsd_deployment_percent),'_',num2str(search_dist),'_',num2str(mc_size),'.mat');
        [var_exist]=persistent_var_exist(app,file_name);
        
        if var_exist==2
            tf_var_exist_array(dist_idx)=0; %%%Already Exists, Do Not Need to Calculate
        else
            tf_var_exist_array(dist_idx)=1; %%%Does NOT Exists, Need to Calculate
        end
    end
    if any(tf_var_exist_array)==1
        tf_calc=1; %%%%%Calculate the move list
    else
        tf_calc=0; %%%%%Do Not Calculate the move list
    end
    
end