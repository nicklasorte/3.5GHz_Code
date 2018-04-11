function [inner_pts,edge1_pts,edge2_pts,outer_pts]=create_3edges_mod3_half_edge_spacing(dpa_input,pt_spacing)
%%%%%Step2: Generate "Binary Pts" and "Edge1 Pts" "Edge2 Pts", with point_spacing
load('downsampled_east10km.mat','downsampled_east10km') 
load('downsampled_west10km.mat','downsampled_west10km') 
load('east_bound200km.mat','east_bound200km')  
load('west_outer_200km.mat','west_outer')

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


dpa_input=unique(dpa_input,'stable','rows');
inner_edge=vertcat(downsampled_east10km,downsampled_west10km);
outer_edge=vertcat(east_bound200km,west_outer);

[inner_line,inner_corner1,inner_corner2]=find_dpa_line_overlap(inner_edge,dpa_input);
[outer_line,outer_corner1,outer_corner2]=find_dpa_line_overlap(outer_edge,dpa_input);

[edge_line1]=cshift_edge_line(dpa_input,inner_corner1,outer_corner1,inner_corner2);
[edge_line2]=cshift_edge_line(dpa_input,inner_corner2,outer_corner2,inner_corner1);


%close all;
figure;
hold on;
plot(dpa_input(:,2),dpa_input(:,1),'-k')
plot(inner_line(:,2),inner_line(:,1),'-sr')
plot(outer_line(:,2),outer_line(:,1),'-db')
plot(edge_line1(:,2),edge_line1(:,1),'-pg')
plot(edge_line2(:,2),edge_line2(:,1),'-pc')
text(inner_corner1(2),inner_corner1(1),strcat('Inner1'))
text(inner_corner2(2),inner_corner2(1),strcat('Inner2'))
text(outer_corner1(2),outer_corner1(1),strcat('Outer1'))
text(outer_corner2(2),outer_corner2(1),strcat('Outer2'))


%%%%Up/Downsample Inner Line for Point spacing
x7=length(inner_line);
dist_steps=NaN(x7-1,1);
for i=1:1:x7-1
    dist_steps(i)=deg2km(distance(inner_line(i,1),inner_line(i,2),inner_line(i+1,1),inner_line(i+1,2)));
end
%inner_line_steps=ceil(nick_sumnan(dist_steps)/pt_spacing)
inner_line_steps=ceil(nansum(dist_steps)/pt_spacing);
if inner_line_steps==1
    inner_line_steps=2;
end
inner_pts=curvspace(inner_line,inner_line_steps);
outer_pts=curvspace(outer_line,inner_line_steps);



x7=length(edge_line1);
dist_steps=NaN(x7-1,1);
for i=1:1:x7-1
    dist_steps(i)=deg2km(distance(edge_line1(i,1),edge_line1(i,2),edge_line1(i+1,1),edge_line1(i+1,2)));
end
%nansum(dist_steps)
%edge_line1_steps=ceil(nick_sumnan(dist_steps)/(pt_spacing*2))
edge_line1_steps=ceil(nansum(dist_steps)/(pt_spacing*2));
if edge_line1_steps==1
    edge_line1_steps=2;
end
edge1_pts=curvspace(edge_line1,edge_line1_steps);

x7=length(edge_line2);
dist_steps=NaN(x7-1,1);
for i=1:1:x7-1
    dist_steps(i)=deg2km(distance(edge_line2(i,1),edge_line2(i,2),edge_line2(i+1,1),edge_line2(i+1,2)));
end
%edge_line2_steps=ceil(nick_sumnan(dist_steps)/(pt_spacing*2))
edge_line2_steps=ceil(nansum(dist_steps)/(pt_spacing*2));
if edge_line2_steps==1
    edge_line2_steps=2;
end
edge2_pts=curvspace(edge_line2,edge_line2_steps);


figure;
hold on;
plot(dpa_input(:,2),dpa_input(:,1),'-k')
plot(edge1_pts(:,2),edge1_pts(:,1),'-sg')
plot(edge2_pts(:,2),edge2_pts(:,1),'-pb')
plot(inner_pts(:,2),inner_pts(:,1),'-oc')
grid on;

end
