function result = swc_array_from_named_tree(named_tree)
    node_count = length(named_tree.parent) ;
    result = zeros(node_count, 7) ;
    result(:,1) = (1:node_count)' ;
    result(:,2) = named_tree.tag_code ;
    result(:,3:5) = named_tree.xyz ;
    result(:,6) = named_tree.r ;
    result(:,7) = named_tree.parent ;
end
