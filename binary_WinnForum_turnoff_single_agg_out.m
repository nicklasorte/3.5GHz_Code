function [azimuth_turn_off_size,agg_azi]=binary_WinnForum_turnoff_single_agg_out(app,monte_carlo_pr_watts,opt_azimuth_search_idx,radar_threshold,cbsd_azimuth,sort_pr_idx,protection_percentile)
            %%%%%%%NaN MC-2000 based upon Neighborhood Restrictions
            [x9,~]=size(monte_carlo_pr_watts);
            
                %%disp_progress(app,strcat('Length of monte_carlo_pr_watts:',num2str(x9)))
            
            %%%Preallocate
            x51=length(opt_azimuth_search_idx);
            azimuth_turn_off_size=NaN(x51,1);
            agg_azi=NaN(x51,1);
            %%%%%%%%%%%%%Azimuth Search Size
            for azimuth_count=1:1:x51
                
                %%%Find CBSD azimuths outside of +/- of 1.5 of temp_azimuth
                temp_azimuth=opt_azimuth_search_idx(azimuth_count)*1.5-1.5;
                left_azimuth=mod(temp_azimuth-1.5,360);
                right_azimuth=mod(temp_azimuth+1.5,360);
                if left_azimuth>right_azimuth
                    idx_azi=find(cbsd_azimuth<left_azimuth & cbsd_azimuth>right_azimuth);
                else
                    idx_azi=find(cbsd_azimuth<left_azimuth | cbsd_azimuth>right_azimuth);
                end
                
                %%%Add loss (25dB) for CBSDs outside the 3 degree beamwidth
                %%%%25dB loss == divide by 316.2278 (in watts)
                azi_correct_mc_pr_watts=monte_carlo_pr_watts;
                azi_correct_mc_pr_watts(idx_azi,:)=monte_carlo_pr_watts(idx_azi,:)/316.2278;
                
                mc_agg_dbm=nick_pow2db(app,nick_sumnan(app,azi_correct_mc_pr_watts)*1000);
                
                if nick_percentile(app,mc_agg_dbm,protection_percentile)>radar_threshold %%%Over Threshold, binary search
                    if x9<=1  %%%%x9 needs to be atleast 2
                        mid=x9; %%%If it is 1, just turn everything off
                        %%%%%monte_carlo_pr_watts
                    else
                        hi=x9;
                        lo=0;
                        
                        [mid,agg_95]=binary_search_agg_percentile(app,hi,lo,azi_correct_mc_pr_watts,sort_pr_idx,radar_threshold,protection_percentile);
                        agg_azi(azimuth_count)=agg_95;
                    end
                    azimuth_turn_off_size(azimuth_count)=mid;
                else
                    %%%Move List is 0
                    azimuth_turn_off_size(azimuth_count)=0;
                    agg_azi(azimuth_count)=mc_agg_dbm;
                end
            end            
        end