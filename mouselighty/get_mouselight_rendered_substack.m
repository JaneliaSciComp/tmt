function substack = get_mouselight_rendered_substack(rendered_folder_name, channel_index, substack_low_corner_ijk1, substack_shape_ijk, zoom_level)
    % substack_least_corner_ijk1 should be in one-based voxel coords
    % the returned stack will include the voxel indicated by substack_least_corner_ijk1
    % zoom level 0 means the most zoomed out stack
    % zoom level 6 (for current mouselight octrees) is the most zoomed-in
    % level
    % substack_least_corner_ijk1 and substack_shape_ijk should be given in terms
    % of full stack *at the desired zoom level*.
    parameter_file_name = fullfile(rendered_folder_name, 'calculated_parameters.jl') ;
    parameters = read_renderer_calculated_parameters_file(parameter_file_name) ;
    maximum_zoom_level = parameters.level_step_count ;
    chunk_shape_ijk = parameters.leaf_shape ;  % xyz order
    if ~exist('zoom_level', 'var') || isempty(zoom_level) ,
        zoom_level = maximum_zoom_level ;
    end
    % note that chunk shape (in voxels) does not change depending on zoom
    % level.  It's just that at zoom level 0 there is 1==8^0 chunk, at zoom level 1
    % there are 8==8^1 chunks, at zoom level 2 there are 64==8^2 chunks,
    % etc
    
    chunks_per_dimension_ijk = 2^zoom_level ;  % same for x, y, and z
    
    %substack_far_corner_ijk1 = substack_origin_ijk1 + substack_shape_ijk - 1 ;  % coords of the voxel in the substack with the largest coords    
    [substack_chunk_low_corner_ijk1, substack_shape_in_chunks_ijk] = ...
        chunk_bounding_box_from_bounding_box(substack_low_corner_ijk1, substack_shape_ijk, chunk_shape_ijk) ;
    
    chunk_aligned_substack_shape_ijk = substack_shape_in_chunks_ijk .* chunk_shape_ijk ;
    chunk_aligned_substack = zeros(chunk_aligned_substack_shape_ijk([2 1 3]), 'uint16') ;
    for i1_chunk_within_substack = 1 : substack_shape_in_chunks_ijk(1) ,
        for j1_chunk_within_substack = 1 : substack_shape_in_chunks_ijk(2) ,
            for k1_chunk_within_substack = 1 : substack_shape_in_chunks_ijk(3) ,
                ijk1_chunk_within_substack = [i1_chunk_within_substack j1_chunk_within_substack k1_chunk_within_substack] ;
                ijk1_chunk_within_stack = substack_chunk_low_corner_ijk1 + ijk1_chunk_within_substack - 1 ;
                if all(1<=ijk1_chunk_within_stack & ijk1_chunk_within_stack<=chunks_per_dimension_ijk) ,
                    octree_path = octree_paths_from_chunk_ijk1s(ijk1_chunk_within_stack, zoom_level) ;
                    try
                        chunk = load_mouselight_rendered_chunk(rendered_folder_name, octree_path, channel_index) ;
                        ijk1_chunk_low_corner_within_substack = chunk_shape_ijk .* (ijk1_chunk_within_substack-1) + 1 ;
                        ijk1_chunk_far_corner_within_substack = ijk1_chunk_low_corner_within_substack + chunk_shape_ijk - 1 ;
                        chunk_aligned_substack(ijk1_chunk_low_corner_within_substack(2):ijk1_chunk_far_corner_within_substack(2) , ...
                                               ijk1_chunk_low_corner_within_substack(1):ijk1_chunk_far_corner_within_substack(1) , ...
                                               ijk1_chunk_low_corner_within_substack(3):ijk1_chunk_far_corner_within_substack(3)) = chunk ;
                    catch err
                        if isequal(err.identifier, 'mouselight:no_such_rendered_chunk') ,
                            % do nothing---load_mouselight_rendered_chunk()
                            % throws this if a chunk does not exist
                        else
                            rethrow(err) ;
                        end
                    end
                            
                end
            end
        end
    end

    % Cut out just the desired part
    chunk_aligned_substack_low_corner_ijk1 = (substack_chunk_low_corner_ijk1-1) .* chunk_shape_ijk + 1 ;
    substack_low_corner_within_chunk_aligned_substack_ijk1 = substack_low_corner_ijk1 - chunk_aligned_substack_low_corner_ijk1 + 1 ;
    substack_far_corner_within_chunk_aligned_substack_ijk1 = substack_low_corner_within_chunk_aligned_substack_ijk1 + substack_shape_ijk - 1 ;
    substack = chunk_aligned_substack(substack_low_corner_within_chunk_aligned_substack_ijk1(2):substack_far_corner_within_chunk_aligned_substack_ijk1(2), ...
                                      substack_low_corner_within_chunk_aligned_substack_ijk1(1):substack_far_corner_within_chunk_aligned_substack_ijk1(1), ...
                                      substack_low_corner_within_chunk_aligned_substack_ijk1(3):substack_far_corner_within_chunk_aligned_substack_ijk1(3)) ;
end
