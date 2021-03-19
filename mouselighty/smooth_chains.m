function smoothed_xyz_from_node_id = smooth_chains(node_ids_from_chain_index, xyz_from_node_id, filter_width)
    smoothed_xyz_from_node_id = xyz_from_node_id ;   
    chain_count = length(node_ids_from_chain_index) ;
    for i = 1 : chain_count ,
        node_ids_in_chain = node_ids_from_chain_index{i} ;
        xyz_for_chain = xyz_from_node_id(node_ids_in_chain,:) ;
        node_count = length(node_ids_in_chain) ;
        smoothed_xyz_for_chain = smooth_chain(1:node_count, xyz_for_chain, filter_width) ;
        smoothed_xyz_from_node_id(node_ids_in_chain,:) = smoothed_xyz_for_chain ;
    end        
end
