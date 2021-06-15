function is_fragment_near_some_neuron_from_fragment_id = ...
        find_fragments_near_neurons(...
            neurons_as_swc_arrays, ...
            neuron_names, ...
            fragment_kd_tree, ...
            fragment_node_count, ...
            fragment_id_from_fragment_node_id, ...
            fragment_count, ...
            radius_in_um)
        
    % neurons_as_swc_arrays is a cell array, each element an centerpoint_count x 7 double array
    % Each row is an SWC-style record: id, type, x, y, z, something i forget,
    % and parent id.  The root has a parent id of -1, and parents come before
    % children.
    
    neuron_count = length(neurons_as_swc_arrays) ;
    is_fragment_near_some_neuron_from_fragment_id = false(fragment_count, 1) ;
    for i = 1:neuron_count ,
        neuron_as_swc_array = neurons_as_swc_arrays{i} ;
        neuron_name = neuron_names{i} ; 
        is_fragment_near_neuron_from_fragment_id = ...
            find_fragments_near_neuron(...
                neuron_as_swc_array, ...
                neuron_name, ...
                fragment_kd_tree, ...
                fragment_node_count, ...
                fragment_id_from_fragment_node_id, ...
                fragment_count, ...
                radius_in_um) ;
        is_fragment_near_some_neuron_from_fragment_id = is_fragment_near_some_neuron_from_fragment_id | is_fragment_near_neuron_from_fragment_id ;    
    end
end