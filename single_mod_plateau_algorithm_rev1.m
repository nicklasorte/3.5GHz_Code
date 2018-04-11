function single_mod_plateau_algorithm_rev1(app,data_label1,sim_number,radar_threshold,margin,maine_exception,rand_pts)


 %%%Check for cell and Process
        temp_filename=strcat(data_label1,'_',num2str(sim_number),'_all_data_stats_binary.mat');
        if exist(temp_filename,'file')==2
            %%%%%%First Check to See if we Processed It
            temp_catb_filename=strcat('mod_',data_label1,'_',num2str(sim_number),'_catb_dist_data.mat');
            var_catb_exist=exist(temp_catb_filename,'file');
            var_catb_exist=0; %%%%%%%%Always redo the calculation
            if var_catb_exist==2
                load(temp_catb_filename,'catb_dist_data')
            elseif var_catb_exist==0
                load(temp_filename,'all_data_stats_binary')
                load('dpa_input.mat','dpa_input')
                %load(strcat(data_label1,'_',num2str(sim_number),'_rand_pts.mat'),'rand_pts')
                temp_sim_pt=rand_pts;
                
                %Process the Data and Find the CatB Distances
                %%%%%Process the Data
                x22=length(all_data_stats_binary);
                catb_dist_data=NaN(x22,1);
                for point_idx=1:1:x22
                    full_stats_catb=all_data_stats_binary{point_idx};
                    if isempty(full_stats_catb)==0
                        %%%%Find the First Point within the agg margin (Original Algorithm)
                        tf_agg=full_stats_catb(:,2)>(radar_threshold+margin);
                        tf_agg2=full_stats_catb(:,2)<(radar_threshold+margin);
                        if all(tf_agg)==1 || all(tf_agg2)==1 %%%%%%This checks to see if all the points are above or below the radar threshold
                            catb_dist_data(point_idx)=NaN(1);
                        else
                            idx_crossing=find(tf_agg==0,1,'first'); %%%%%Find the First Point within the agg margin
                            if isempty(idx_crossing)==1
                                [idx_crossing,~]=size(full_stats_catb);
                            end
                            catb_dist_data(point_idx)=full_stats_catb(idx_crossing,1);
                            
                            %%%%%%%%%%%%Check for the plateau with a small move list
                            movelist_size=max(full_stats_catb(:,3));
                            idx_crossing_diff=NaN(1);
                            if movelist_size<maine_exception
                                agg_diff=-1*diff(full_stats_catb(1:idx_crossing-1,2));
                                sum_agg_diff=NaN(idx_crossing-2,1);
                                for j=1:1:(idx_crossing-2)
                                    sum_agg_diff(j)=sum(agg_diff(j:idx_crossing-2));
                                end
                                idx_crossing_diff=find(sum_agg_diff<margin,1,'first');
                                if isempty(idx_crossing_diff)==1
                                    catb_dist_data(point_idx)=full_stats_catb(idx_crossing,1);
                                elseif idx_crossing_diff==1
                                    catb_dist_data(point_idx)=NaN(1);
                                else
                                    catb_dist_data(point_idx)=full_stats_catb(idx_crossing_diff,1);
                                end
                            end
                        end
                    end
                end
                
                [m_dist,m_idx]=max(catb_dist_data);
                figure;
                hold on;
                plot(dpa_input(:,2),dpa_input(:,1),'-k')
                temp_sim_pt
                scatter3(temp_sim_pt(:,2),temp_sim_pt(:,1),catb_dist_data,20,catb_dist_data,'filled')
                catb_dist_data(isnan(catb_dist_data))=-Inf;
                [~,sort_idx]=sort(catb_dist_data,'descend');
                catb_dist_data(isinf(catb_dist_data))=NaN(1);
                if length(catb_dist_data)>10
                    plot(temp_sim_pt(sort_idx(1:10),2),temp_sim_pt(sort_idx(1:10),1),'sr','MarkerSize',10,'LineWidth',2)
                end
                plot(temp_sim_pt(m_idx,2),temp_sim_pt(m_idx,1),'ok','MarkerSize',20,'LineWidth',4)
                colormap(jet);
                title({strcat(data_label1),strcat('CatB Neighborhood Distances [km]')})
                c=colorbar;
                c.Label.String='[km]';
                grid on;
                filename1=strcat('mod_',data_label1,'_DistHeatMap1_',num2str(sim_number),'.png');
                saveas(gcf,char(filename1))
                
                figure;
                hold on;
                num_bins=ceil((ceil(max(catb_dist_data))-floor(min(catb_dist_data)))/10)+1;
                histogram(catb_dist_data,'Normalization','probability','NumBins',num_bins)
                line([max(catb_dist_data),max(catb_dist_data)],[min(ylim),max(ylim)],'Color','k','LineWidth',4)
                xlabel('CatB Neighborhood Distance [km]')
                ylabel('Probability')
                grid on;
                title({strcat(data_label1,': Histogram: CatB Neighborhood Distance'),strcat('Neighborhood Distance:',num2str(max(catb_dist_data)),'km')})
                filename1=strcat('mod_',data_label1,'Histogram_CatB_Dist',num2str(sim_number),'.png');
                saveas(gcf,char(filename1))
                
                figure;
                hold on;
                plot(catb_dist_data,'-ob')
                grid on;
                grid on;
                ylabel('Aggregate Interference [dBm]')
                xlabel('CatB Neighborhood Distance')
                title({strcat(data_label1),strcat('CatB Neighborhood:',num2str(max(catb_dist_data)),'km')})
                filename1=strcat('mod_',data_label1,'_AllPoints_',num2str(sim_number),'.png');
                saveas(gcf,char(filename1))
                
                %%%Find Max Distance and Look at Individual Plot
                [~,point_idx]=max(catb_dist_data);
                figure;
                hold on;
                full_stats_catb=all_data_stats_binary{point_idx};
                plot(full_stats_catb(:,1),full_stats_catb(:,2),'-sk')
                line([min(xlim),max(xlim)],[radar_threshold,radar_threshold],'Color','r','LineWidth',2)
                fill([min(xlim),max(xlim),max(xlim),min(xlim),min(xlim)],[radar_threshold+1,radar_threshold+1,min(ylim),min(ylim),radar_threshold+1],'g','FaceAlpha',0.25)
                line([min(xlim),max(xlim)],[radar_threshold,radar_threshold],'Color','r','LineWidth',2)
                line([catb_dist_data(point_idx),catb_dist_data(point_idx)],[min(ylim),max(ylim)],'Color','b','LineWidth',2)
                grid on;
                grid on;
                ylabel('Aggregate Interference [dBm]')
                xlabel('CatB Neighborhood Distance')
                title({strcat(data_label1,':',num2str(point_idx)),strcat('CatB Neighborhood:',num2str(catb_dist_data(point_idx)),'km')})
                filename1=strcat('mod_',data_label1,'_SinglePoint_',num2str(sim_number),'_',num2str(point_idx),'.png');
                saveas(gcf,char(filename1))
                
                save(strcat('mod_',data_label1,'_',num2str(sim_number),'_catb_dist_data.mat'),'catb_dist_data')
            end
            strcat('CatB Distance:',num2str(max(catb_dist_data)))
        end
        
end