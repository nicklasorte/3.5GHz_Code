function [monte_carlo_pr_watts]=generation_single_mc_iter(app,sim_mc_count,mc_iter,temp_all_Pr,rand_seed1,reliability)
            
            mc_count=sim_mc_count(mc_iter);
            %%%%%%%Generate 1 MC Iteration, then split
            [x9,~]=size(temp_all_Pr);
            
            rng(rand_seed1+mc_count);%For Repeatability
            rand_numbers=rand(x9,1)*(max(reliability)-min(reliability))+min(reliability); %Create Random Number within Max/Min or reliability
            
            [ind_prev]=nearestpoint(app,rand_numbers,reliability,'previous');
            [ind_next]=nearestpoint(app,rand_numbers,reliability,'next');
            
            %%%Check for NaN in ind_prev
            if isempty(find(isnan(ind_prev),1))==1
                %No NaN
            else
                idx_nan=isnan(ind_prev);
                ind_prev(idx_nan)=1;
            end
            
            %%%%Intrep
            remainder=rand_numbers-reliability(ind_prev);
            span=reliability(ind_next)-reliability(ind_prev);
            
            %%%%%Preallocate
            temp_Lb_interp=NaN(x9,1);
            for t1=1:1:x9
                temp_diff_Pr=temp_all_Pr(t1,ind_prev(t1))-temp_all_Pr(t1,ind_next(t1));
                temp_Lb_interp(t1)=temp_all_Pr(t1,ind_prev(t1))-(temp_diff_Pr*(remainder(t1)/span(t1)));
             end
            monte_carlo_pr_watts=nick_db2pow(app,temp_Lb_interp)/1000; %%%%Convert to watts
        end