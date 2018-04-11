function [temp_cata_list,cata_idx_inside]=create_temp_list(app,list_cbsd_cata,sim_pt,cata_neighborhood)


[x4,y4]=size(list_cbsd_cata);
cata_distance=deg2km(distance(sim_pt(1)*ones(x4,1),sim_pt(2)*ones(x4,1),list_cbsd_cata(:,1),list_cbsd_cata(:,2)));
[cata_sort_dist_val,cata_sort_dist_idx]=sort(cata_distance,'ascend');

cata_idx_point=find(cata_sort_dist_val<=cata_neighborhood,1,'last');
if isempty(cata_idx_point)==1
    cata_idx_inside=NaN(1);
    temp_cata_list=NaN(1,y4);
else
    cata_idx_inside=cata_sort_dist_idx(1:1:cata_idx_point);
    temp_cata_list=list_cbsd_cata(cata_idx_inside,:);
end
temp_cata_idx_inside=cata_idx_inside;
clear cata_idx_inside;
cata_idx_inside=temp_cata_idx_inside(~isnan(temp_cata_idx_inside));

end