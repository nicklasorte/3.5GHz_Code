# 3.5GHz_Code

This code is for the CatB Neighborhood distance sims.

Warning: This software uses a .dll for the ITM prop model which is not included. You will have to modify WinnForum_ITMP2P_parchunk_self_contained_GUI.m to call your implementation of ITM.

To start sim: open and run START_HERE_mulitpoint_neighborhood_sim_rev1.m
(Tested in Matlab2017b)

You will need to download (file is too large for GitHub), double unzip (unzip,unzip) soft_cell_urban_census_data_rev4 into the same folder as the rest of the code.  -->Download Link : https://app.box.com/s/skvzaly11zo5yxcfhmiuwb69sn4mb7q0

The randomized CBSD output is a .csv and .mat with the CBSD: [Latitude, Longitude, Antenna Height, NLCD Code, EIRP, Randomized Azimuth 1, Randomized Azimuth 2, Randomized Azimuth 3, Population of Census Tract of Deployed CBSD]

For the CatA CBSDs, Randomized Azimuth 1 is used to number the CBSDs, and Randomized Azimuth 2 and Randomized Azimuth 3 are NaN.
