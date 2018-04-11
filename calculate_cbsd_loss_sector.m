function [catb_sector_ant_loss,rep_list_catb_azi]=calculate_cbsd_loss_sector(app,list_cbsd_catb_azis,sim_pt)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%This is where we will do the sector loss
            %%%%%%%%%%Split the CatB into 3 CBSDs, each with an azimuth
            rep_list_catb_azi=vertcat(list_cbsd_catb_azis(:,1:6),list_cbsd_catb_azis(:,[1:5,7]),list_cbsd_catb_azis(:,[1:5,8]));
            
            %%%%%%Azimuth from CatB to Radar
            catb_to_radar_azi=azimuth(rep_list_catb_azi(:,1),rep_list_catb_azi(:,2),sim_pt(1),sim_pt(2));

            %%%%Find the Off Angle Azimuth from CatB to Radar
            raw_catb_azi_off_axis=rep_list_catb_azi(:,6)-catb_to_radar_azi;
            
            %%%Need to have the azi from -180 to 180
            idx_azi_over_180=find(raw_catb_azi_off_axis>180);
            idx_azi_under_neg180=find(raw_catb_azi_off_axis<-180);
            
            catb_azi_off_axis=raw_catb_azi_off_axis;
            catb_azi_off_axis(idx_azi_over_180)=360-raw_catb_azi_off_axis(idx_azi_over_180);
            catb_azi_off_axis(idx_azi_under_neg180)=360+raw_catb_azi_off_axis(idx_azi_under_neg180);
            
            %%%%%%%%Calculate CatB antenna loss
            %2. Calculate Antenna Loss (dB) for 360 degrees
            %Normalized to zero
            radar_beamwidth=65; %%%%%From ITU-R M.2292
            temp_ant_loss=NaN(360,1);
             for i=1:1:360 %Half a Degree
                theta=i;
                temp_ant_loss(i)=-12*((theta-180)/radar_beamwidth).^2;
                if temp_ant_loss(i)<-20
                    temp_ant_loss(i)=-20; %%%%%%%%From R2-SGN-20 (0112), min CBSD antenna loss is -20dB
                end
             end
             
             %%%%Create Idx to find loss for each CBSD
            azi_loss_idx=round(catb_azi_off_axis+180);
            azi_loss_idx_zero_idx=find(azi_loss_idx==0);
            azi_loss_idx(azi_loss_idx_zero_idx)=360;
              
            %%%%%%CatB Antenna Sector Loss
            catb_sector_ant_loss=temp_ant_loss(azi_loss_idx);

%              close all;
%              figure;
%              hold on;
%              histogram(catb_sector_ant_loss)
%              grid on;
%              
%              title({strcat('Histogram: CatB Antenna Loss for Single Protection Point')})
%              filename1=strcat('Example_Ant_loss1.png');
%              saveas(gcf,char(filename1))


end