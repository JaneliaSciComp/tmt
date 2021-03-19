function [shape_xyz, origin, spacing, jaws_origin, resolution_step_count] = load_sample_shape_origin_and_spacing(rendered_folder_name)
%     transform_file_name = fullfile(sample_folder_name, 'transform.txt') ;    
%     transform_as_raw_struct = configparser(transform_file_name) ;
%         % has fields, ox, oy, oz, sx, sy, sz, all in nm
%         % also nl, the number of levels in the octree
%     resolution_level_count = transform_as_raw_struct.nl ;
%     resolution_step_count = resolution_level_count - 1 ;
%     origin = [ transform_as_raw_struct.ox transform_as_raw_struct.oy transform_as_raw_struct.oz]/1e3 ;  % nm -> um
%     spacing = [ transform_as_raw_struct.sx transform_as_raw_struct.sy transform_as_raw_struct.sz]/1e3/2^resolution_step_count ;  % nm -> um
%         % determine the spacing of the voxels at the bottom level
%     % Note that this is not *exactly* the origin used by Jaws as of this writing (2019-07-16).
%     % But it's intended to be the location of the voxel *center* of the
%     % 'lowest-index' voxel in the stack.
%     lowest_resolution_stack_file_name = fullfile(sample_folder_name, 'default.0.tif') ;        
%     lowest_resolution_stack = read_16bit_grayscale_tif(lowest_resolution_stack_file_name) ;
%     low_rez_shape_yxz = size(lowest_resolution_stack) ;
%     low_rez_shape_xyz = low_rez_shape_yxz([2 1 3]) ;  % reorder
%     shape_xyz = 2^resolution_step_count * low_rez_shape_xyz ;
%     
%     % Compute the slightly-shifted origin used by JaWS
%     jaws_origin = spacing .* floor(origin ./ spacing) ;
    
    
    parameter_file_name = fullfile(rendered_folder_name, 'calculated_parameters.jl') ;
    parameters = read_renderer_calculated_parameters_file(parameter_file_name) ;
    resolution_step_count = parameters.level_step_count ;
    chunk_shape_xyz = parameters.leaf_shape ;  % xyz order
    spacing = parameters.spacing ;
    origin = parameters.origin ;
    shape_xyz = 2^resolution_step_count * chunk_shape_xyz ;
    
    % Compute the slightly-shifted origin used by JaWS
    jaws_origin = spacing .* floor(origin ./ spacing) ;
end
