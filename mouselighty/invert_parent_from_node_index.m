function children_from_node_index  = invert_parent_from_node_index(parent_from_node_index) 
    node_count = length(parent_from_node_index) ;
    children_from_node_index = cell(node_count, 1) ;
    for node_index = 1 : node_count ,
        parent_node_index = parent_from_node_index(node_index) ;
        if parent_node_index > 0 ,
            original_children = children_from_node_index{parent_node_index} ;
            children_from_node_index{parent_node_index} = horzcat(original_children, node_index) ;
        end
    end
end
