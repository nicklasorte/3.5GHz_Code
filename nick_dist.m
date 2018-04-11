function [varout] = nick_dist(X,Y)
    varout=deg2km(distance(X(:,1),X(:,2),Y(:,1),Y(:,2)));
end

