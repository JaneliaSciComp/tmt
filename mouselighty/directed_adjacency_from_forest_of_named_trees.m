function [dA, xyz, tree_index_from_node_id] = directed_adjacency_from_forest_of_named_trees(forest)
    % Count the nodes in all trees
    tree_count = length(forest) ;
    node_count_from_tree_index = arrayfun(@(named_tree)(length(named_tree.parent)), ...
                                          forest) ;
    node_count = sum(node_count_from_tree_index) ;
    edge_count = node_count - tree_count ;
    
    % Dimension the head and tail arrays
    head = zeros(edge_count, 1) ;
    tail = zeros(edge_count, 1) ;
    xyz = zeros(node_count, 3) ;
    tree_index_from_node_id = zeros(node_count, 1) ;
    
    % Process the trees, accumulating the eventual head, tail
    nodes_added_so_far = 0 ;
    edges_added_so_far = 0 ;    
    for tree_index = 1 : tree_count ,
        tree = forest(tree_index) ;        
        tree_xyz = tree.xyz ;
        tree_node_count = size(tree_xyz, 1) ;
        xyz(nodes_added_so_far+1:nodes_added_so_far+tree_node_count,:) = tree_xyz ;
        tree_index_from_node_id(nodes_added_so_far+1:nodes_added_so_far+tree_node_count,:) = tree_index ;
        [tree_head, tree_tail] = edges_from_named_tree(tree) ;
        tree_edge_count = length(tree_head) ;
        head(edges_added_so_far+1:edges_added_so_far+tree_edge_count) = nodes_added_so_far + tree_head ;
        tail(edges_added_so_far+1:edges_added_so_far+tree_edge_count) = nodes_added_so_far + tree_tail ;
        nodes_added_so_far = nodes_added_so_far + tree_node_count ;
        edges_added_so_far = edges_added_so_far + tree_edge_count ;
    end
    
    % Combine into a dA sparse matrix
    dA = sparse(tail, head, 1, node_count, node_count) ;
end



function [head, tail] = edges_from_named_tree(named_tree)
    % Get the parent of each node (parent means next node root-ward)
    parent = named_tree.parent ;
    
    % Need an array with the explicit node indices
    node_count = length(parent) ;
    node_index = (1:node_count)' ;
    
    % trim the root node off, since it has no parent
    head = parent(2:end) ;
    tail = node_index(2:end) ;
end
