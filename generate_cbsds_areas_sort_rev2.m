function generate_cbsds_areas_sort_rev2(sim_pts,catb_radius,cata_radius)

load('sort_cell_urban_census_data_rev4.mat','sort_cell_urban_census_data_rev4')
sort_cell_urban_census_data=sort_cell_urban_census_data_rev4;

[census_bound_catb]=census_bound_radius(sim_pts,catb_radius);
[census_bound_cata]=census_bound_radius(sim_pts,cata_radius);

%%%%%%%Find the urban_area_bound that are full/partially in the census_bound_catb
[cata_inpoly_idx,catb_inpoly_idx]=filter_urban_areas(census_bound_catb,census_bound_cata);
save('cata_inpoly_idx.mat','cata_inpoly_idx');
save('catb_inpoly_idx.mat','catb_inpoly_idx');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Generate CBSDS
[no_cut_list_cbsd_cata_azi]=gen_cata_census_tract_data_input(cata_inpoly_idx,sort_cell_urban_census_data);
[no_cut_list_cbsd_catb_azi]=gen_catb_census_tract_data_input(catb_inpoly_idx,sort_cell_urban_census_data);

%%%%%%%%%Cut CBSDs outside of Census Bound
tf_cata=inpolygon(no_cut_list_cbsd_cata_azi(:,2),no_cut_list_cbsd_cata_azi(:,1),census_bound_cata(:,2),census_bound_cata(:,1));
tf_catb=inpolygon(no_cut_list_cbsd_catb_azi(:,2),no_cut_list_cbsd_catb_azi(:,1),census_bound_catb(:,2),census_bound_catb(:,1));

list_cbsd_catb_azi=no_cut_list_cbsd_catb_azi(tf_catb,:);
list_cbsd_cata_azi=no_cut_list_cbsd_cata_azi(tf_cata,:);  

list_cbsd_cata_azi(:,6)=1:1:length(list_cbsd_cata_azi); %%%%%Numbering the CatAs in one the Azimuth Columns

save('list_cbsd_catb_azi.mat','list_cbsd_catb_azi');
save('list_cbsd_cata_azi.mat','list_cbsd_cata_azi');

cata_table=table(list_cbsd_cata_azi);
writetable(cata_table,'list_cata.csv')

catb_table=table(list_cbsd_catb_azi);
writetable(catb_table,'list_catb.csv')

close all;
load('cell_urban_area_bound.mat','cell_urban_area_bound')
figure
hold on;
for i=1:1:length(catb_inpoly_idx)
    temp_data=cell_urban_area_bound{catb_inpoly_idx(i)};
    plot(temp_data(:,2),temp_data(:,1),'-b')
end
for i=1:1:length(cata_inpoly_idx)
    temp_data=cell_urban_area_bound{cata_inpoly_idx(i)};
    plot(temp_data(:,2),temp_data(:,1),'-g')
end
plot(list_cbsd_cata_azi(:,2),list_cbsd_cata_azi(:,1),'og','MarkerSize',1)
plot(list_cbsd_catb_azi(:,2),list_cbsd_catb_azi(:,1),'or','MarkerSize',1)
plot(census_bound_catb(:,2),census_bound_catb(:,1),'m')
plot(census_bound_cata(:,2),census_bound_cata(:,1),'y')
if length(sim_pts(:,1))==1 
    plot(sim_pts(:,2),sim_pts(:,1),'ok')
else
    plot(sim_pts(:,2),sim_pts(:,1),'-k')
end
grid on;
axis square;
ylabel('Latitude')
xlabel('Longitude')
title({'Initialization Area for 3.5 GHz Simulation'})
filename1=strcat('initial_parameters1.png');
saveas(gcf,char(filename1))


end




















