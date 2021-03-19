function is_fragment_near_neuron_from_fragment_id = ...
        find_fragments_near_neuron(neuron_as_swc_array, ...
                                   neuron_name, ...
                                   fragment_kd_tree, ...
                                   fragment_node_count, ...
                                   fragment_id_from_fragment_node_id, ...
                                   fragment_count, ...
                                   radius_in_um)

    neuron_node_count = size(neuron_as_swc_array, 1) ;
                               
    xyz_from_neuron_node_id = neuron_as_swc_array(:,3:5) ;
    
    nearby_fragment_node_ids_from_neuron_node_id = rangesearch(fragment_kd_tree, xyz_from_neuron_node_id, radius_in_um) ;
    
    is_fragment_node_near_neuron_from_fragment_node_id = false(fragment_node_count, 1) ;
    for neuron_node_id = 1 : neuron_node_count ,
        nearby_fragment_node_ids = nearby_fragment_node_ids_from_neuron_node_id{neuron_node_id} ;
        is_fragment_node_near_neuron_from_fragment_node_id(nearby_fragment_node_ids) = true ;
    end
    fragment_ids_near_neuron = fragment_id_from_fragment_node_id(is_fragment_node_near_neuron_from_fragment_node_id) ;  % may contain repeats
    
    is_fragment_near_neuron_from_fragment_id = false(fragment_count, 1) ;
    is_fragment_near_neuron_from_fragment_id(fragment_ids_near_neuron) = true ;
end
