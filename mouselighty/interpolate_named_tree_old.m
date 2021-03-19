function result = interpolate_named_tree(named_tree, maximum_spacing)
    % Do piecewise linear interpolation on tree, to make it so that
    % all edges are no longer than maximum_spacing
    
    dA = directed_adjacency_from_named_tree(named_tree) ;
    tree_adjacency = max(dA, dA') ;    
    xyz_from_node_id = named_tree.xyz ;
    chains = chains_from_tree(tree_adjacency) ;
    root_node_id = find(named_tree.parent==-1) ;
    [interpolated_chains, result_xyz_from_node_id, interpolated_root_node_id] = interpolate_chains(chains, xyz_from_node_id, maximum_spacing, root_node_id) ;
    interpolated_edges = edges_from_chains(interpolated_chains) ;
    result_adjacency = undirected_adjacency_from_edges(interpolated_edges) ;    
    result = named_tree_from_undirected_graph(result_adjacency, result_xyz_from_node_id, named_tree.name, named_tree.color, interpolated_root_node_id) ;
end
