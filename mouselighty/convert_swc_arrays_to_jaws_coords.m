function result = convert_swc_arrays_to_jaws_coords(swc_arrays_in_erhan_coords, origin, spacing, jaws_origin)
    % origin is 3x1, in um, is the erhan-style origin (the outside corner of the
    % low-index corner voxel)
    % spacing is 3x1, is the voxel spacing in um
    % jaws_origin is 3x1, in um, is the jaws-style origin (the center of the
    % low-index corner voxel)
    % everything in xyz order 
    result = cellfun(@(swc_array_in_erhan_coords)(convert_swc_array_to_jaws_coords(swc_array_in_erhan_coords, origin, spacing, jaws_origin)), ...
                     swc_arrays_in_erhan_coords, ...
                     'UniformOutput', false) ;
end
