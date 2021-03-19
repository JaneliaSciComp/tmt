function dA_rooted_tree = rooted_tree_from_connected_graph(A, root_node_index)
    % Turns an undirected connected graph and a root node into a rooted tree
    % represented as a digraph with edges pointing towards the root.
    %
    % A should be the adjacency matrix for an undirected graph, and thus
    % symmetric.  All edges must also have unity weight.
    
    % Find the shortest path to the root from each node    
    node_count = size(A,1) ;
    [~,parent_node_id_from_node_id] = graphtraverse(A, root_node_index, 'Method', 'BFS', 'Directed', false) ;  % NB: pred(root_node_id)==0
    node_id_from_node_id = (1:node_count)' ;
    is_not_root = (parent_node_id_from_node_id>=1) ;

    % Make the adjacency graph of the rooted tree, with arrows pointing
    % rootward
    dA_rooted_tree = sparse(node_id_from_node_id(is_not_root), parent_node_id_from_node_id(is_not_root), 1, node_count, node_count) ; 
end
