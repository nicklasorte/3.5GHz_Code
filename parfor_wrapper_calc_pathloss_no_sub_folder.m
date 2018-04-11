function parfor_wrapper_calc_pathloss_no_sub_folder(app,rand_pts,sim_number,full_list_cbsd_catb,full_list_cbsd_cata,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss,point_idx)

        sim_pt=rand_pts(point_idx,:);
        
        %%%%%%Check/Calculate path loss: CatB --> Very Slow Because of Larger Distances
        wrapper_CatB_Pr_dBm_noload(app,point_idx,sim_number,full_list_cbsd_catb,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag);

        %%%%%%%%Check/Calculate path loss: CatA ---> Fast Because of Smaller Distances
        wrapper_CatA_Pr_dBm_noload(app,point_idx,sim_number,full_list_cbsd_cata,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag,building_loss);

end