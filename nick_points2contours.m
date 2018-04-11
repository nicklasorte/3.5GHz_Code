function [final_bound]=nick_points2contours(unique_gps_pts)

    %%%%%%%%%%%%%%%%%%%%%
    %Points to multiple contours
    %1. Find the two closest points and connect them and repeat until a point has two connections 
    %2. Take point out of search if they have two connections

    
[x2,y2]=size(unique_gps_pts);
    
    
%Preallocate
connect_count=zeros(x2,1); %This table will have 0,1,2
connect_array=zeros(x2,3); %This table will keep track of the connections
connect_array(:,1)=1:1:x2;

%%%%Initialize matrix
first_connect=unique_gps_pts;
[temp_idx2, temp_dist2]=knnsearch(first_connect,first_connect,'k',2); 
min_idx1=temp_idx2(:,2);
min_dist1=temp_dist2(:,2);

mod_div=x2/100;
for i=1:1:x2
    clc;
        i/x2*100
        
%     if mod(i,mod_div)==0 %This will really slow it down 
%         clc;
%         i/x2*100
%     end
        
    if all(isnan(min_dist1))==1  %This regenerates the temp_idx and temp_dist when it is empty
        [temp_idx2, temp_dist2]=knnsearch(first_connect,first_connect,'k',3);
        min_idx1=temp_idx2(:,2);
        min_dist1=temp_dist2(:,2);
        
        %Check for points that are connected and replace those with the next closest point
        tf_dup=find(connect_count==1);
        for j=1:1:length(tf_dup)
            if any(connect_array(tf_dup(j),2:3)==min_idx1(tf_dup(j)))==1
                min_dist1(tf_dup(j))=temp_dist2(tf_dup(j),3);
                min_idx1(tf_dup(j))=temp_idx2(tf_dup(j),3);
            end
        end
    end

    %%%%%%%%%Find the closest points
    %%%%%%%%%These are the two points to connect
    [~,ind1]=min(min_dist1);
    ind2=min_idx1(ind1);
    
    min_dist1(ind1)=NaN(1); %Delete the possibility of those points getting matched again
    min_dist1(ind2)=NaN(1); %Delete the possibility of those points getting matched again
    
    min_idx1(ind1)=NaN(1); 
    min_idx1(ind2)=NaN(1);
    
    %%%%%%%%%%%%%Add +1 to the connect_count and check
    connect_count(ind1)=connect_count(ind1)+1;
    connect_count(ind2)=connect_count(ind2)+1;

    if connect_count(ind1)==1
        connect_array(ind1,2)=ind2; %Create the connection
    elseif connect_count(ind1)==2
        connect_array(ind1,3)=ind2;
        first_connect(ind1,:)=NaN(1,2); %Delete the point in first_connect(ind1)
        
        %%%%Search rest of min_dist1 and set those to zero
        tf1=find(min_idx1==ind1);
        if isempty(tf1)==0
            for j=1:1:length(tf1)
                min_dist1(tf1(j))=NaN(1);
            end
        end
    end
    
    if connect_count(ind2)==1
        connect_array(ind2,2)=ind1;
    elseif connect_count(ind2)==2
        connect_array(ind2,3)=ind1;
        first_connect(ind2,:)=NaN(1,2); %Delete the point in first_connect(ind2)
        
        %%%%Search rest of min_dist1 and set those to zero
        tf2=find(min_idx1==ind2);
        if isempty(tf2)==0
            for j=1:1:length(tf2)
                min_dist1(tf2(j))=NaN(1);
            end
        end
    end
end

find(connect_array(:,3)==0);



%%%%%Now we have to take the connect array and form the bound(s)
temp_connect_array=connect_array;
bound_marker=1; %Counts the number of bounds
idx_marker=1; %Start at point 1 and start building from there
bound=cell(x2,1);

%We need to check for the case where there are two points way out and they didn't get connected.
%Remove them
idx_line=find(temp_connect_array(:,3)==0);
temp_connect_array(idx_line,:)=NaN(length(idx_line),3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%We don't need to optimize this part
while((nansum(temp_connect_array(:,2))+nansum(temp_connect_array(:,3)))~=0)
    %Check idx_marker if it is all NaN, if so, increase bound_marker
    if all(isnan(temp_connect_array(idx_marker,2:3)))==1
        idx_marker=find(temp_connect_array(:,2:3)>0,1,'first');
        clc;
        bound_marker=bound_marker+1
    end
    
    %Connect the idx_marker with the second column
    temp_bound=bound{bound_marker};
    
    temp_con_array=temp_connect_array(idx_marker,2:3);
    con_idx=find(temp_con_array>0,1,'first');
    idx_marker2=temp_con_array(con_idx);
        
    if isempty(temp_bound)==1
        temp_bound=vertcat(unique_gps_pts(idx_marker,:),unique_gps_pts(idx_marker2,:));
        bound{bound_marker}=temp_bound;
    else
        temp_bound=vertcat(temp_bound,unique_gps_pts(idx_marker2,:));
        bound{bound_marker}=temp_bound;
    end
    
% %     %Then clear the temp_connect_array for those points idx_marker and idx_marker2
    zero_idx1= temp_connect_array(idx_marker,:)==idx_marker2;
    temp_connect_array(idx_marker,zero_idx1)=NaN(1);
    zero_idx2= temp_connect_array(idx_marker2,:)==idx_marker;
    temp_connect_array(idx_marker2,zero_idx2)=NaN(1);

    %Then set idx_marker to idx_marker2
    idx_marker=idx_marker2;
end


ind_bound=find(~cellfun('isempty', bound));
x3=length(ind_bound);
final_bound=cell(x3,1);
for i=1:1:x3
    final_bound{i}=bound{i};
end

    
end