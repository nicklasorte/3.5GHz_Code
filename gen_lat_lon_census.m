function [lat_pt,lon_pt]=gen_lat_lon_census(temp_single_tract)

    %%%%%%%%%Used for randomization (Uniform)
    temp_min_lat=min(temp_single_tract(:,1));
    temp_max_lat=max(temp_single_tract(:,1));
    temp_min_lon=min(temp_single_tract(:,2));
    temp_max_lon=max(temp_single_tract(:,2));
    tf_gen=0; %%%Flag to generate
    counter=0;
    while (tf_gen==0 && counter<100)
        counter=counter+1;
        %%%Generate Random Points inside DPA
        lon_rand=rand(1);
        lat_rand=rand(1);

        lon_pt=lon_rand*(temp_max_lon-temp_min_lon)+temp_min_lon;
        lat_pt=lat_rand*(temp_max_lat-temp_min_lat)+temp_min_lat;

        %%%%Check to see if it falls inside the Census tract
        tf_gen=inpolygon(lon_pt,lat_pt,temp_single_tract(:,2),temp_single_tract(:,1));
    end

end


% 
% 
% 
% 
% function [lat_pt,lon_pt]=gen_lat_lon_census(temp_single_tract)
% 
%     %%%%%%%%%Used for randomization (Uniform)
%     temp_min_lat=min(temp_single_tract(:,1));
%     temp_max_lat=max(temp_single_tract(:,1));
%     temp_min_lon=min(temp_single_tract(:,2));
%     temp_max_lon=max(temp_single_tract(:,2));
%     tf_gen=0; %%%Flag to generate
%     while (tf_gen==0)
%         %%%Generate Random Points inside DPA
%         lon_rand=rand(1);
%         lat_rand=rand(1);
% 
%         lon_pt=lon_rand*(temp_max_lon-temp_min_lon)+temp_min_lon;
%         lat_pt=lat_rand*(temp_max_lat-temp_min_lat)+temp_min_lat;
% 
%         %%%%Check to see if it falls inside the Census tract
%         tf_gen=inpolygon(lon_pt,lat_pt,temp_single_tract(:,2),temp_single_tract(:,1));
%     end
% 
% end