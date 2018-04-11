function [rand_seed2]=rand_seed2_generator(app,turn_off_size95,point_idx,mc_size)
            rng(point_idx+turn_off_size95);%For Repeatability
            tempx=ceil(rand(1)*mc_size);
            tempy=ceil(rand(1)*mc_size);
            rand_seed2=tempx+tempy;
        end