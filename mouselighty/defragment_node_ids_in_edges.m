function [edges_using_new_node_ids, xyz_from_new_node_id, original_node_id_from_new_node_id] = ...
        defragment_node_ids_in_edges(edges_using_original_node_ids, xyz_from_original_node_id)
    % Renumbers the nodes, to eliminate gaps in the numbering.  In output,
    % node ids go from 1 to node_count.
    edge_count = size(edges_using_original_node_ids, 1) ;  % edge count in the post-decimation graph
    original_node_ids_in_edges = edges_using_original_node_ids(:) ;
    [original_node_id_from_new_node_id, ~, new_node_ids_in_edges] = unique(original_node_ids_in_edges) ;
    edges_using_new_node_ids = reshape(new_node_ids_in_edges, [edge_count 2]) ;    
    xyz_from_new_node_id = xyz_from_original_node_id(original_node_id_from_new_node_id,:) ;
end
