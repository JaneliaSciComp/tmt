function [result_adjacency, result_xyz_from_node_id] = interpolate_tree(tree_adjacency, xyz_from_node_id, maximum_spacing)
    % Do piecewise linear interpolation on tree, to make it so that
    % all edges are no longer than maximum_spacing
    
    chains = chains_from_tree(tree_adjacency) ;
    [interpolated_chains, result_xyz_from_node_id] = interpolate_chains(chains, xyz_from_node_id, maximum_spacing) ;
    interpolated_edges = edges_from_chains(interpolated_chains) ;
    result_adjacency = undirected_adjacency_from_edges(interpolated_edges) ;    
end
