function [rand_seed1]=rand_seed1_generator(app,catb_distance_search,cata_distance_search,point_idx,mc_size)
            rng(catb_distance_search+cata_distance_search+point_idx);%For Repeatability
            tempx=ceil(rand(1)*mc_size);
            tempy=ceil(rand(1)*mc_size);
            rand_seed1=tempx+tempy;
        end