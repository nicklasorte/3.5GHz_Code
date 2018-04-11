function parfor_wrapper_union_move_list_no_sub_folder(app,search_dist_array,dist_idx,cbsd_deployment_percent,rand_pts,sim_number,parallel_flag)

    search_dist=search_dist_array(dist_idx);
    %%%%%%%%%First, check to see if the union of the move list exists
    file_name2=strcat('union_master_turn_off_idx_',num2str(cbsd_deployment_percent),'_',num2str(search_dist),'.mat');
    [file_exist]=persistent_var_exist(app,file_name2);
    
    if file_exist==0 %%%The File Does not exist, we will calculate it
        [x22,~]=size(rand_pts);%%%%%%Number of move lists
        union_master_turn_off_idx=NaN(1);
        for point_idx=1:1:x22
            file_name=strcat('master_turn_off_idx_',num2str(point_idx),'_',num2str(sim_number),'_',num2str(cbsd_deployment_percent),'_',num2str(search_dist),'.mat');
            %%%%Check if file exists
            [var_exist]=persistent_var_exist(app,file_name);
            if var_exist==2 %%%%%%Load
                retry_load=1;
                while(retry_load==1)
                    try
                        load(file_name)
                        retry_load=0;
                    catch
                        retry_load=1;
                        pause(0.1)
                    end
                end
                detail_who=whos('-file',file_name);
                temp_variable=eval(detail_who.name);
                
                if ~isempty(temp_variable)==1 %%%%Do not union if empty
                    if all(~isnan(temp_variable))==1
                        temp_union2=NaN(1);
                        temp_union2=union(union_master_turn_off_idx,temp_variable); %%%%We might need to do unique as it seems likes we are running out of memory.
                        union_master_turn_off_idx=unique(temp_union2); %%%%We might need to do unique as it seems likes we are running out of memory, but we assume union is also doing unique.
%                         if parallel_flag==0
%                             disp_progress(app,strcat('Distance:',num2str(search_dist),' -- Point IDX:',num2str(point_idx),' -- Size of Union:',num2str(length(union_master_turn_off_idx))))
%                         end
                        temp_union2=NaN(1);
                    else
                        %%%%%%There is a NaN File, delete the NaN File
                        if parallel_flag==0
                            disp_progress(app,strcat('NaN Movelist . . .',file_name))
                        end
                        %delete(file_name)
                    end
                end
                if parallel_flag==0
                    disp_progress(app,strcat('Distance:',num2str(search_dist),' -- Point IDX:',num2str(point_idx),' -- Size of Union:',num2str(length(union_master_turn_off_idx))))
                end
            end
        end
        retry_save=1;
        while(retry_save==1)
            try
                save(file_name2,'union_master_turn_off_idx')
                retry_save=0;
            catch
                retry_save=1;
                pause(0.1)
            end
        end
    end
    
end