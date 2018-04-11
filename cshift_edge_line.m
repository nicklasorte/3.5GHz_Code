function [edge_line2]=cshift_edge_line(dpa_input,inner_corner2,outer_corner2,inner_corner1)

    %%%%Keep shifting until idx_corner is #1
    cshift_dpa_input=dpa_input; %%%Initialize
    tf_shift=all(round(inner_corner2,2)==round(cshift_dpa_input(1,:),2));

    while(tf_shift==0)
        cshift_dpa_input=circshift(cshift_dpa_input,1,1);
        tf_shift=all(round(inner_corner2,2)==round(cshift_dpa_input(1,:),2));
    end

    %%%%See if inner_corner2--> outer_corner2 goes through inner_corner1,if so, flip
    [~,~,idx_temp_inner_corner2]=intersect(round(inner_corner2,2),round(cshift_dpa_input,2),'rows');
    [~,~,idx_temp_outer_corner2]=intersect(round(outer_corner2,2),round(cshift_dpa_input,2),'rows');
    
    temp_line=cshift_dpa_input(idx_temp_inner_corner2:idx_temp_outer_corner2,:);
    [~,~,idx_temp_inner_corner1]=intersect(round(inner_corner1,2),round(temp_line,2),'rows');
    
    if isempty(idx_temp_inner_corner1)==1
        %%%%nothing
    else
        %%%Do not Flip and shift
        cshift_dpa_input=flipud(cshift_dpa_input);
        tf_shift=all(round(inner_corner2,2)==round(cshift_dpa_input(1,:),2));

        while(tf_shift==0)
            cshift_dpa_input=circshift(cshift_dpa_input,1,1);
            tf_shift=all(round(inner_corner2,2)==round(cshift_dpa_input(1,:),2));
        end
        [~,~,idx_temp_inner_corner2]=intersect(round(inner_corner2,2),round(cshift_dpa_input,2),'rows');
        [~,~,idx_temp_outer_corner2]=intersect(round(outer_corner2,2),round(cshift_dpa_input,2),'rows');
        temp_line=cshift_dpa_input(idx_temp_inner_corner2:idx_temp_outer_corner2,:);
    end
    
    edge_line2=unique(vertcat(inner_corner2,temp_line,outer_corner2),'stable','rows');

    
end