function stack = get_mouselight_rendered_substack_simple(rendered_folder_name, channel_index, stack_origin, stack_shape)
    % stack_origin should be in one-based voxel coords
    % the returned stack will include the voxel indicated by stack_origin
    parameter_file_name = fullfile(rendered_folder_name, 'calculated_parameters.jl') ;
    parameters = read_renderer_calculated_parameters_file(parameter_file_name) ;
    level_step_count = parameters.level_step_count ;
    chunk_shape = parameters.leaf_shape ;
    [chunk_path, stack_origin_chunk_ijk] = octree_path_from_ijk1(stack_origin, level_step_count, chunk_shape) ;
    stack_far_corner_chunk_ijk = stack_origin_chunk_ijk + stack_shape -1 ;
    if any(stack_far_corner_chunk_ijk > chunk_shape) ,
        error('mouselight:stackMustBeInOneChunk', 'Requested stack has to be contained within one chunk') ;
    end
    chunk = load_mouselight_rendered_chunk(rendered_folder_name, chunk_path, channel_index) ;
    stack = chunk(stack_origin_chunk_ijk(2):stack_far_corner_chunk_ijk(2), ...
                  stack_origin_chunk_ijk(1):stack_far_corner_chunk_ijk(1), ...
                  stack_origin_chunk_ijk(3):stack_far_corner_chunk_ijk(3)) ;
end
