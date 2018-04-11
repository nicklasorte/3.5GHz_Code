function [val]=nick_percentile(app,temp_rand,pct)
            if pct==100
                newarr = sort(temp_rand);
                val = newarr(length(temp_rand));
            else
                len = length(temp_rand);
                ind = floor(pct/100*(len+1));
                newarr = sort(temp_rand);
                val = newarr(ind);
            end
        end