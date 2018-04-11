function [cell_turn_off_size,cell_agg_azi]=sub_function_movelist_agg_out(app,sim_mc_count,rand_seed1,reliability,temp_Pr_dBm,radar_threshold,sort_pr_idx,opt_azimuth_search_idx,cbsd_azimuth)
            %%%%Wrapper MC_count_chunk
            x1=length(sim_mc_count);
            
            %%%Preallocate
            cell_turn_off_size=cell(x1,1);
            cell_agg_azi=cell(x1,1);
            
            for mc_iter=1:1:x1
                %%%%Generate MC Iteration
                monte_carlo_pr_watts=generation_single_mc_iter(app,sim_mc_count,mc_iter,temp_Pr_dBm,rand_seed1,reliability); %1.51 Seconds
                
                %%%%Calculate Move List for Single MC Iteration
                protection_percentile=100; %Because we are doing single iterations
                %cell_turn_off_size{mc_iter}=binary_WinnForum_turnoff_single_temp(app,monte_carlo_pr_watts,opt_azimuth_search_idx,radar_threshold,cbsd_azimuth,sort_pr_idx,protection_percentile);
                [cell_turn_off_size{mc_iter},cell_agg_azi{mc_iter}]=binary_WinnForum_turnoff_single_agg_out(app,monte_carlo_pr_watts,opt_azimuth_search_idx,radar_threshold,cbsd_azimuth,sort_pr_idx,protection_percentile);
            end
        end