function smoothed_xyz_from_node_id = smooth_chain(node_id_from_chain_index, xyz_from_node_id, filter_width)
    node_id_from_working_node_index = node_id_from_chain_index(2:end-1) ;  % Leave end points alone
    smoothed_xyz_from_node_id = xyz_from_node_id ;   
    if isempty(node_id_from_working_node_index) ,
        return
    end        
    z_from_working_node_index = xyz_from_node_id(node_id_from_working_node_index,3) ;
    new_z_from_working_node_index = medfilt1(medfilt1(z_from_working_node_index, filter_width), filter_width) ;       
    smoothed_xyz_from_node_id(node_id_from_working_node_index,3) = new_z_from_working_node_index ;
end
