        function [list_cata_on,list_catb_on,idx_cata_on,idx_catb_on]=find_on_cbsd_agg_check_with_idx(app,list_cbsd_cata,list_cbsd_catb,union_turn_off_idx)
            x51=length(list_cbsd_cata);
            x52=length(list_cbsd_catb);
            
            idx_find_off_cata=union_turn_off_idx<=x51;
            idx_find_off_catb=union_turn_off_idx>x51;
            
            idx_turn_off_cata=union_turn_off_idx(idx_find_off_cata);
            idx_turn_off_catb=union_turn_off_idx(idx_find_off_catb)-x51;
                       
            idx_cata_on=setxor(1:1:x51,idx_turn_off_cata);
            idx_catb_on=setxor(1:1:x52,idx_turn_off_catb);
            
            list_cata_on=list_cbsd_cata(idx_cata_on,:);
            list_catb_on=list_cbsd_catb(idx_catb_on,:);
        end