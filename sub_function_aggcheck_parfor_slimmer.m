function [cell_agg_check]=sub_function_aggcheck_parfor_slimmer(app,sim_mc_count,rand_seed1,reliability,all_Pr_dBm,opt_azimuth_search_idx,cbsd_azimuth)
            x1=length(sim_mc_count);
            
            %%%Preallocate
            cell_agg_check=cell(x1,1);
            
            for mc_iter=1:1:x1
                %%%%Generate MC Iteration
                monte_carlo_pr_watts=generation_single_mc_iter(app,sim_mc_count,mc_iter,all_Pr_dBm,rand_seed1,reliability); %1.51 Seconds
                
                %%%%Calculate Aggregate Check
                cell_agg_check{mc_iter}=WinnForum_agg_check_single_slimmer(app,monte_carlo_pr_watts,opt_azimuth_search_idx,cbsd_azimuth);
            end
        end