function [var_exist]=persisent_file_exist(app,file_name3)

retry_exist=1;
while(retry_exist==1)
    try
        var_exist=exist(file_name3,'file');
        retry_exist=0;
    catch
        retry_exist=1;
        pause(0.1)
    end
end
end