function result = interpolate_chain_xyzs(xyz_from_node_index, maximum_spacing)
    % Get length of chain    
    dxyz_from_edge_index = diff(xyz_from_node_index) ;        
    ds_from_edge_index = sqrt( sum(dxyz_from_edge_index.^2, 2) ) ;  % length of each edge in the chain of nodes 
    path_length = sum(ds_from_edge_index) ;
    edge_count = length(ds_from_edge_index) ;
    estimated_result_edge_count = max(ceil(path_length/maximum_spacing), edge_count) ;
    estimated_result_node_count = ceil(1.2 * (estimated_result_edge_count+1)) ;  % Pad so we (hopefully) don't need to reallocate array
    result = zeros(estimated_result_node_count, 3) ;
    result(1,:) = xyz_from_node_index(1, :) ;
    result_node_count_so_far = 1 ;
    for i = 1 : edge_count ,
        start_node_xyz = xyz_from_node_index(i  ,:) ;
        end_node_xyz   = xyz_from_node_index(i+1,:) ;
        edge_length = ds_from_edge_index(i) ;
        if edge_length <= maximum_spacing ,
            % the easy case---no interpolation needed
            result(result_node_count_so_far+1,:) = end_node_xyz ;
            result_node_count_so_far = result_node_count_so_far + 1 ;
        else
            % the harder case---need to interpolate
            new_edge_count_for_this_edge = ceil(edge_length/maximum_spacing) ;
            new_edge_length = edge_length/new_edge_count_for_this_edge ;
            new_dxyz = new_edge_length/edge_length * (end_node_xyz - start_node_xyz) ;
            new_xyzs = start_node_xyz + new_dxyz .* (1:new_edge_count_for_this_edge)' ;
            result(result_node_count_so_far+1:result_node_count_so_far+new_edge_count_for_this_edge,:) = new_xyzs ;
            result_node_count_so_far = result_node_count_so_far + new_edge_count_for_this_edge ;            
        end
    end
    % trim the result to its true size
    result = result(1:result_node_count_so_far, :) ;
end
