function [A, ijk1_from_node_id] = skel2graph_core(raw_edges_and_radii, stack_shape_ijk)    
    %raw_edge_count = size(raw_edges_and_radii, 1) ;
    voxel_id_pair_from_raw_edge_id = raw_edges_and_radii(:,[1 2]) ;
    %radius_from_raw_edge_id = raw_edges_and_radii(:,3) ;
    
    voxel_id_from_raw_half_edge_index = voxel_id_pair_from_raw_edge_id(:) ;
    [voxel_id_from_node_id, ~, node_id_from_raw_half_edge_index] = ...
        unique(voxel_id_from_raw_half_edge_index) ;  % each unique voxel becomes a node, with a node id
    [ijk1_from_node_id(:,1), ijk1_from_node_id(:,2), ijk1_from_node_id(:,3)] = ind2sub(stack_shape_ijk, voxel_id_from_node_id) ;
    node_id_pair_from_edge_index = reshape(node_id_from_raw_half_edge_index, [], 2) ;
    
    % Eliminate edges with same node at either end
    node_id_pair_from_new_edge_index = node_id_pair_from_edge_index(node_id_pair_from_edge_index(:,1)~=node_id_pair_from_edge_index(:,2),:) ;
    
    % Make a sparse adjacency matrix
    dA = sparse(node_id_pair_from_new_edge_index(:,1), ...
                node_id_pair_from_new_edge_index(:,2), ...
                1, ...
                max(node_id_pair_from_new_edge_index(:)), ...
                max(node_id_pair_from_new_edge_index(:))) ;
    A = max(dA',dA) ;  % adjacency matrix    
end
