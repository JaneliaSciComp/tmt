function [node_index_sans_root, parent_sans_root] = edges_from_named_tree(named_tree)
    % Get the parent of each node (parent means next node root-ward)
    parent = named_tree.parent ;
    
    % Need an array with the explicit node indices
    node_count = length(parent) ;
    node_index = (1:node_count)' ;
    
    % trim the root node off, since it has no parent
    parent_sans_root = parent(2:end) ;
    node_index_sans_root = node_index(2:end) ;
end
