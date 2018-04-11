function [temp_Pr]=WinnForum_ITMP2P_parchunk_self_contained_GUI(app,list_cbsd,sim_pt,reliability,confidence,radar_height,FreqMHz,Tpol,parallel_flag)

if parallel_flag==0
    disp_progress(app,strcat('Starting ITM . . . '))
end

%%%%%%WinnForum ITM Self Contained
[x1,~]=size(list_cbsd);
x2=length(reliability);

NET.addAssembly(fullfile('C:\USGS', 'SEADLib.dll'));
itmp=ITMAcs.ITMP2P;
TerHandler=int32(1); % 0 for GLOBE, 1 for USGS
TerDirectory='C:\USGS\';

%%%%%Mode of Variability (MDVAR)	13 (broadcast p2p)

%Climate	Derived by using ITU-R.P.617
%%%Persisent Load
retry_load=1;
while(retry_load==1) %%%This will continue to pin the move_list_function
    try
        load('TropoClim.mat','TropoClim')
        retry_load=0;
    catch
        retry_load=1;
        if parallel_flag==0
            disp_progress(app,strcat('Error in ITM --> Loading TropoClim'))
        end
        pause(1)
    end
end

TropoClim_data=int32(TropoClim);
tropo_value_radar=get_txt_value_GUI(app,sim_pt(1),sim_pt(2),TropoClim_data); %Gets the Climate of each point

%%%Surface refractivity: Derived by using ITU-R.P.452
%%%Persisent Load
retry_load=1;
while(retry_load==1) %%%This will continue to pin the move_list_function
    try
        load('data_N050.mat','data_N050')
        retry_load=0;
    catch
        retry_load=1;
        if parallel_flag==0
            disp_progress(app,strcat('Error in ITM --> Loading data_N050'))
        end
        pause(1)
    end
end

data_N050_data=data_N050;

Dielectric=25.0;
Conduct=0.02;

ConfPct=confidence/100;
RelPct=reliability/100;

RxHtm=radar_height;
RxLat=sim_pt(1);
RxLon=sim_pt(2);

%%%%Preallocate
dBloss=NaN(x1,x2);
for i=1:x1  %%%%For Now, send in CBSD one at a time
    
    if parallel_flag==0
        disp_progress(app,strcat('ITM:',num2str(i/x1*100),'%'))
    end
    
    TxLat=list_cbsd(i,1);
    TxLon=list_cbsd(i,2);
    TxHtm=list_cbsd(i,3);
    
    %Calculate Radio Climate
    tropo_value=find_tropo_itu617_parfor_GUI(app,list_cbsd(i,1:2),TropoClim_data,tropo_value_radar);
    RadClim=int32(tropo_value); % 1 Equatorial, 2 Continental Subtorpical, 3 Maritime Tropical, 4 Desert, 5 Continental Temperate, 6 Maritime Over Land, 7 Maritime Over Sea
    
    %Calculate Refractivity
    Refrac=find_refrac_itu452_par_GUI(app,list_cbsd(i,1:2),sim_pt,data_N050_data);
    temp_dBloss=NaN(1);
    try
        [temp_dBloss]=itmp.ITMp2pAryRels(TxHtm,RxHtm,Refrac,Conduct,Dielectric,FreqMHz,RadClim,Tpol,ConfPct,RelPct,TxLat,TxLon,RxLat,RxLon,TerHandler,TerDirectory);
    catch
        temp_dBloss=1000;
        save(strcat('ERROR_NaN_prop_CBSDnum',num2str(i),'_',num2str(sim_pt(1)),'_',num2str(sim_pt(2)),'.mat'),'temp_dBloss')
    end
    dBloss(i,:)=double(temp_dBloss);

end

%%%%Calculate PR --> Output Pr_dBm
temp_Pr=list_cbsd(:,5)-dBloss;
end