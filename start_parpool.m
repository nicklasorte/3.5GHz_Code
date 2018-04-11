function [poolobj,cores]=start_parpool(app,parallel_flag)
    
 if parallel_flag==1
     poolobj=gcp('nocreate');
     if isempty(poolobj)
         poolobj=parpool;
     end
     cores=poolobj.NumWorkers
 else
     poolobj=NaN(1);
     poolobj=poolobj(~isnan(poolobj))
     cores=1
 end

end