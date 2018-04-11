function [val]=nick_pow2db(app,input)
            val=10.*log10(1000.*input)-30;
        end