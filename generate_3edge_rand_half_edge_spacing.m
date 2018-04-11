function [rand_pts]=generate_3edge_rand_half_edge_spacing(data_label1,sim_number,number_rand_pts,dpa_input,pt_spacing)

%%%%%%%%%%Generate Random Points
file_name_list=strcat(data_label1,'_',num2str(sim_number),'_rand_pts.mat');
var_exist_list=exist(file_name_list,'file');
if var_exist_list==0 %%%|| var_exist_list==2
    %number_rand_pts=100;
    [rand_pts]=generate_rand_pts_uni_island_filter(dpa_input,sim_number,number_rand_pts);
    
    %%%%%%%%%%%Add 3 Edges to the rand points
    %%%%%Generate "Inner Pts" and "Edge1 Pts" "Edge2 Pts", with point_spacing
    %[inner_pts,edge1_pts,edge2_pts,outer_pts]=create_3edges_mod3_full_edge(dpa_input,pt_spacing);
    [inner_pts,edge1_pts,edge2_pts,outer_pts]=create_3edges_mod3_half_edge_spacing(dpa_input,pt_spacing);
    save(strcat(data_label1,'_',num2str(sim_number),'_inner_pts.mat'),'inner_pts')
    save(strcat(data_label1,'_',num2str(sim_number),'_outer_pts.mat'),'outer_pts')
    save(strcat(data_label1,'_',num2str(sim_number),'_edge1_pts.mat'),'edge1_pts')
    save(strcat(data_label1,'_',num2str(sim_number),'_edge2_pts.mat'),'edge2_pts')
        
    %%%%Need to add Inner, Edge1, and Edge2 Pts to the beginning of the rand_pts
    rand_pts=vertcat(inner_pts,edge1_pts,edge2_pts,rand_pts);
    uni_rand_pts= unique(rand_pts,'rows');
    size(rand_pts)
    clear rand_pts;
    rand_pts=uni_rand_pts;
    size(rand_pts)
    save(strcat(data_label1,'_',num2str(sim_number),'_rand_pts.mat'),'rand_pts')
    
    figure;
    hold on;
    plot(dpa_input(:,2),dpa_input(:,1),'-k')
    plot(rand_pts(:,2),rand_pts(:,1),'or')
    grid on;
end
load(strcat(data_label1,'_',num2str(sim_number),'_rand_pts.mat'),'rand_pts')

end