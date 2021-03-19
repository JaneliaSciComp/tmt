function [sample_stacks, sample_radius] = sample_rendered_data(sample_folder_path, node_ijks, desired_sample_count)
    sample_radius = [10 10 3]  ;  % x-y voxels
    sample_shape = 2*sample_radius+1 ;
    sample_stacks = zeros(sample_shape(1), sample_shape(2), sample_shape(3), desired_sample_count) ;
    node_count = size(node_ijks, 1) ;
    shuffled_fragment_node_indices = randperm(node_count) ;
    last_sample_index = 0 ;
    pbo = progress_bar_object(desired_sample_count) ;
    for i = 1:2*desired_sample_count ,
        if last_sample_index == desired_sample_count ,
            break 
        end
        fragment_node_index = shuffled_fragment_node_indices(i) ;
        node_ijk = node_ijks(fragment_node_index, :) ;
        sample_offset = node_ijk - sample_radius ;
        try
            sample_stack = get_mouselight_rendered_substack(sample_folder_path, 0, sample_offset, sample_shape) ;
            sample_index = last_sample_index + 1 ;
            sample_stacks(:,:,:,sample_index) = sample_stack ;
            pbo.update(sample_index) ;
            last_sample_index = sample_index ;
        catch err
            if isequal(err.identifier, 'mouselight:stackMustBeInOneChunk') ,                
                % ignore
            else
                rethrow(err) ;
            end
        end
    end
end
