function node_ids_from_chain_id = chains_from_tree_with_id_tracking(A_tree, node_id_from_tree_node_index, root_tree_node_index)
    % Given symmetric adjacency matrix A representing an undirected tree,
    % returns a set of chains.  The first and last node of each chain is a
    % node_id into A, and each is a nexus node.  All nodes in A are
    % included in at least one chain.

%     % For debugging
%     G = graph(dA) ;
%     figure() ;
%     plot(G) ;

    node_count = length(node_id_from_tree_node_index) ;

    if node_count == 0 ,
        node_ids_from_chain_id = cell(1,0) ;
        return
    end

    % Select a root node, if none supplied
    if ~exist('root_tree_node_index', 'var') || isempty(root_tree_node_index) ,
        % Use a branch node as the root, unless none exist, if which case
        % use a leaf node.
        % Note that unless A_tree is a chain, this guarantees that each
        % leaf node is the start of exactly one chain, and that each chain end
        % is a branch node.
        degree_from_tree_node_index = full(sum(A_tree)) ;
        branch_node_tree_indices = find(degree_from_tree_node_index>=3) ;
        if ~isempty(branch_node_tree_indices) ,
            root_tree_node_index = branch_node_tree_indices(1) ;
        else
            leaf_node_tree_indicess = find(degree_from_tree_node_index==1) ;
            if ~isempty(leaf_node_tree_indicess) ,
                root_tree_node_index = leaf_node_tree_indicess(1) ;
            else
                if isscalar(A_tree) ,
                    % graph is a singleton node
                    root_tree_node_index = 1 ;
                else
                    error('A_tree is has no branch nodes and no leaf nodes, and is not a singleton: Cannot be a tree')
                end
            end
        end
    end
    
    % Get a rooted directed tree from the undirected tree
    % The 'root' node will basically be a random leaf, which is what we
    % want.
    %dA = spanning_tree_adjacency_from_graph_adjacency(A_tree) ;    
    dA = rooted_tree_from_connected_graph(A_tree, root_tree_node_index) ;
    
    % 
    node_ids_from_chain_id = chains_from_rooted_tree_with_id_tracking(dA, node_id_from_tree_node_index) ;
end
