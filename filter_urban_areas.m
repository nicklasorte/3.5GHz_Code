function [cata_inpoly_idx,catb_inpoly_idx]=filter_urban_areas(census_bound_catb,census_bound_cata)

%%%%%%%Find the urban_area_bound that are full/partially in the census_bound_catb
load('cell_urban_area_bound.mat','cell_urban_area_bound')
x14=length(cell_urban_area_bound);
inpoly_idx=NaN(x14,1);
for i=1:1:x14
   temp_urban=cell_urban_area_bound{i};
   tf1=any(inpolygon(temp_urban(:,2),temp_urban(:,1),census_bound_catb(:,2),census_bound_catb(:,1)));
   if tf1==1
       inpoly_idx(i)=i;
   end
end
catb_inpoly_idx=inpoly_idx(~isnan(inpoly_idx));

x14=length(cell_urban_area_bound);
inpoly_idx=NaN(x14,1);
for i=1:1:x14
   temp_urban=cell_urban_area_bound{i};
   tf1=any(inpolygon(temp_urban(:,2),temp_urban(:,1),census_bound_cata(:,2),census_bound_cata(:,1)));
   if tf1==1
       inpoly_idx(i)=i;
   end
end
cata_inpoly_idx=inpoly_idx(~isnan(inpoly_idx));

end