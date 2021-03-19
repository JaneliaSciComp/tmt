function dA = directed_adjacency_from_named_tree(named_tree)
    % Get the parent of each node (parent means next node root-ward)
    parent = named_tree.parent ;
    
    % Need an array with the explicit node indices
    node_count = length(parent) ;
    node_index = (1:node_count)' ;
    
    % trim the root node off, since it has no parent
    parent_sans_root = parent(2:end) ;
    node_index_sans_root = node_index(2:end) ;
    
    % dA: directed adjacency graph.  A sparse matrix that represents the
    % directed edges that point from a node to the next node soma-ward (or,
    % more generally, rootward).
    dA = sparse(node_index_sans_root,parent_sans_root, 1, node_count, node_count) ;
end
