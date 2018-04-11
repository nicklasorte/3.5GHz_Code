function [sort_pr_idx]=create_sorted_movelist(app,all_Pr_dBm,reliability)
            %%%%%%%%%%%Create Sorted Move List
            mid_idx=reliability==50;
            mid_Pr_dBm=all_Pr_dBm(:,mid_idx);
            
            %%%Sort power received at radara, and then this is the order of turn off.
            [~,sort_pr_idx]=sort(mid_Pr_dBm,'descend');
        end