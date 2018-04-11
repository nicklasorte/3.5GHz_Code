function [CatA_Pr_dBm]=wrapper_CatA_Pr_dBm(app,point_idx,sim_number,full_list_cbsd_cata,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss)

    file_name=strcat('CatA_Pr_dBm',num2str(point_idx),'_',num2str(sim_number),'.mat');
    [var_exist]=persistent_var_exist(app,file_name);
    if var_exist==0
        [pre_CatA_Pr_dBm]=WinnForum_ITMP2P_parchunk_self_contained_GUI(app,full_list_cbsd_cata,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag);
        CatA_Pr_dBm=pre_CatA_Pr_dBm-building_loss;
        %%%%%%Persistent Save
        retry_save=1;
        while(retry_save==1)
            try
%                 if parallel_flag==0
%                     disp_progress(app,strcat('Saving CatA_Pr_dBm . . . '))
%                 end
                save(strcat('CatA_Pr_dBm',num2str(point_idx),'_',num2str(sim_number),'.mat'),'CatA_Pr_dBm')
                retry_save=0;
            catch
                retry_save=1;
                pause(1)
            end
        end
    else
        %%%%%%Persistent Load
        retry_load=1;
        while(retry_load==1)
            try
%                 if parallel_flag==0
%                     disp_progress(app,strcat('Loading CatA_Pr_dBm . . . '))
%                 end
                load(strcat('CatA_Pr_dBm',num2str(point_idx),'_',num2str(sim_number),'.mat'),'CatA_Pr_dBm')
                retry_load=0;
            catch
                retry_load=1;
                pause(1)
            end
        end
    end
        
end