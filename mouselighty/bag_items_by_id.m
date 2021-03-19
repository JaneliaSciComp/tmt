function [items_from_bag_index, id_from_bag_index] = bag_items_by_id(id_from_item_index, items)
    id_from_bag_index = unique(id_from_item_index) ;    
    bag_count = length(id_from_bag_index) ;
    items_from_bag_index = cell(1, bag_count) ;
    for bag_index = 1 : bag_count ,
        id = id_from_bag_index(bag_index) ;
        items_matching_id = items(id_from_item_index==id) ;
        items_from_bag_index{bag_index} = items_matching_id ;        
    end
end
    