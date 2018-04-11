function [single_agg_check_dBm]=WinnForum_agg_check_single_slimmer(app,monte_carlo_pr_watts,opt_azimuth_search_idx,cbsd_azimuth)
            %%%Preallocate
            single_agg_check_dBm=NaN(length(opt_azimuth_search_idx),1);
            %%%%%%%%%%%%%Azimuth Search Size
            for azimuth_count=1:1:length(opt_azimuth_search_idx)
                
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
                
                single_agg_check_dBm(azimuth_count)=nick_pow2db(app,nick_sumnan(app,azi_correct_mc_pr_watts)*1000);
            end
        end