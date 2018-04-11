function [rand_pts_uni]=generate_rand_pts_uni_island_filter(dpa_input,sim_number,number_rand_pts)

%%%%%%%%%%%%%%%%Mod Random Points to filter out islands
full_dpa_input=dpa_input;

% % idx_nan=find(isnan(dpa_input(:,1)));
% % if ~isempty(idx_nan)==1
% %     dpa_islands=dpa_input(idx_nan(1):end,:);
% %     dpa_input=dpa_input(1:idx_nan(1)-1,:);
% %     tf_islands=1;
% % else
% %     tf_islands=0;
% % end


idx_nan=find(isnan(dpa_input(:,1)));
if ~isempty(idx_nan)==1
    %%%%Find the largest piece and make that the dpa_input
    for i=1:1:length(idx_nan)+1
        if i==1
            segment_size(i)=length(1:1:idx_nan(i)-1);
        elseif i==length(idx_nan)+1
            segment_size(i)=length(idx_nan(i-1)+1:1:length(dpa_input));
        else
            segment_size(i)=length(idx_nan(i-1)+1:1:idx_nan(i)-1);
        end
    end
    [~,max_idx]=max(segment_size);
    if max_idx==1
        dpa_input=dpa_input(1:1:idx_nan(max_idx)-1,:);
    elseif i==length(idx_nan)+1
        dpa_input=dpa_input(idx_nan(max_idx-1)+1:1:length(dpa_input),:);
    else
        dpa_input=dpa_input(idx_nan(max_idx-1)+1:1:idx_nan(max_idx)-1,:);
    end
    tf_islands=1;
else
    tf_islands=0;
end




%%%%%Uniform Random Points
%%%%%%DPA Bounds
x_max=max(dpa_input(:,2));
x_min=min(dpa_input(:,2));
y_max=max(dpa_input(:,1));
y_min=min(dpa_input(:,1));

rng(sim_number);%For Repeatability
%%%Preallocate
marker1=1;
rand_pts_uni=NaN(number_rand_pts,2);
while (marker1<=number_rand_pts)
    %%%Generate Random Points inside DPA
    x_rand=rand(1);
    y_rand=rand(1);
    
    x_pt=x_rand*(x_max-x_min)+x_min;
    y_pt=y_rand*(y_max-y_min)+y_min;
    
    %%%%Check to see if it falls inside the DPA
    tf1=inpolygon(x_pt,y_pt,dpa_input(:,2),dpa_input(:,1));
    
    if tf1==1
        if tf_islands==1
            %%%Check to see if it falls outside of the islands
%             tf2=inpolygon(x_pt,y_pt,dpa_islands(:,2),dpa_islands(:,1));
%             if tf2==0
%                 rand_pts_uni(marker1,:)=horzcat(y_pt,x_pt);
%                 marker1=marker1+1;
%             end
            tf2=inpolygon(x_pt,y_pt,full_dpa_input(:,2),full_dpa_input(:,1));
            if tf2==1
                rand_pts_uni(marker1,:)=horzcat(y_pt,x_pt);
                marker1=marker1+1;
            end
        else
            rand_pts_uni(marker1,:)=horzcat(y_pt,x_pt);
            marker1=marker1+1;
        end
    end
end


%close all;
figure;
hold on;
scatter(rand_pts_uni(:,2),rand_pts_uni(:,1),3,'or')
plot(dpa_input(:,2),dpa_input(:,1),'-k','LineWidth',2)
% if tf_islands==1
%     plot(dpa_islands(:,2),dpa_islands(:,1),'-k','LineWidth',2)
% end

end