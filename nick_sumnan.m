function [y]=nick_sumnan(app,varargin)
            narginchk(2,2);
            y = sum(varargin{:},'omitnan');
        end