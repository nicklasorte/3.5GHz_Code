function [opt_azimuth_search_idx,cbsd_azimuth]=find_cbsd_count_azi(app,input_pt,temp_all_list_cbsd)
    %1. Find the Azimuth from the ship to the CBSD (This calculates it for all in parallel
    cbsd_azimuth=azimuth(input_pt(1),input_pt(2),temp_all_list_cbsd(:,1),temp_all_list_cbsd(:,2));
    azi_cbsd_count=NaN(240,1);
    for n=1:1:240 %We should start with the azimuth that has the largest number of CBSDs for each azimuth rotation
        temp_azimuth=n*1.5-1.5;
        %%%Find CBSD azimuths outside of +- of 1.5 of temp_azimuth
        left_azimuth=mod(temp_azimuth-1.5,360);
        right_azimuth=mod(temp_azimuth+1.5,360);
        if left_azimuth>right_azimuth
            idx_azi1=find(cbsd_azimuth>=left_azimuth | cbsd_azimuth<=right_azimuth);
        else
            idx_azi1=find(cbsd_azimuth>=left_azimuth & cbsd_azimuth<=right_azimuth);
        end
        azi_cbsd_count(n)=length(idx_azi1);
    end
    %%%%%%%%%The easiest thing to do is not search azimuth with 0 CBSDs in the main beam. This cuts it roughly in half.
    azi_search_idx=find(azi_cbsd_count>0);
    non_zero_azi_cbsd_count=azi_cbsd_count(azi_search_idx);
    [~,sort_non_zero_azi_idx]=sort(non_zero_azi_cbsd_count,'descend');
    opt_azimuth_search_idx=azi_search_idx(sort_non_zero_azi_idx);
end