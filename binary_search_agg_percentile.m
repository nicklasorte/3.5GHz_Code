function [mid,agg_95]=binary_search_agg_percentile(app,hi,lo,azi_correct_mc_pr_watts,sort_pr_idx,radar_threshold,protection_percentile)

if hi-lo<=1
    mid=hi;
else
    while((hi-lo)>1) %%%Binary Search
        mid=ceil((hi+lo)/2);

        %%%Find Aggregate for 0:1:mid turnoff
        temp_mc_pr_watts=azi_correct_mc_pr_watts;
        idx_cut=sort_pr_idx(1:1:mid);
        temp_mc_pr_watts(idx_cut,:)=NaN(1);
        
        %Re-calculate Aggregate Power
        mc_agg_dbm=nick_pow2db(app,nick_sumnan(app,temp_mc_pr_watts)*1000);
        agg_95=nick_percentile(app,mc_agg_dbm,protection_percentile);
        
        if agg_95<radar_threshold
            hi=mid;
        else
            lo=mid;
        end
    end
    
    mid=hi;
    %%%Find Aggregate for 0:1:mid turnoff
    temp_mc_pr_watts=azi_correct_mc_pr_watts;
    idx_cut=sort_pr_idx(1:1:mid);
    temp_mc_pr_watts(idx_cut,:)=NaN(1);
    
    %Re-calculate Aggregate Power
    mc_agg_dbm=nick_pow2db(app,nick_sumnan(app,temp_mc_pr_watts)*1000);
    agg_95=nick_percentile(app,mc_agg_dbm,protection_percentile);
    
%     agg_95
%     mid
%     hi
    
    if agg_95>=radar_threshold
        agg_95
        mid
        hi
        label_stop='ERROR_MOVE_LIST_AGG_OVER_THRESHOLD'
        placeholder=NaN(1);
        save('ERROR_MOVE_LIST_AGG_OVER_THRESHOLD.mat','placeholder')
    end
end
end