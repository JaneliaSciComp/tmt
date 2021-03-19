function result = convert_swc_array_to_jaws_coords(swc_array_in_erhan_coords, origin, spacing, jaws_origin)
    % origin is 3x1, in um, is the erhan-style origin (the outside corner of the
    % low-index corner voxel)
    % spacing is 3x1, is the voxel spacing in um
    % jaws_origin is 3x1, in um, is the jaws-style origin (the center of the
    % low-index corner voxel)
    % everything in xyz order    
    xyzs_in_erhan_coords = swc_array_in_erhan_coords(:,3:5) ;
    %unrounded_ijk1s = (xyzs_in_erhan_coords - origin) ./ spacing + 0.5 ;  % these are one-based ijks
    %xyzs_in_jaws_coords = jaws_origin + spacing .* (unrounded_ijk1s-1) ;  % um, n x 3
    xyzs_in_jaws_coords = jaws_origin + xyzs_in_erhan_coords - origin - spacing/2 ;  % um, n x 3
    
    % result is like swc_array_in_erhan_coords, but with xyz coords overwritten
    result = swc_array_in_erhan_coords ;
    result(:,3:5) = xyzs_in_jaws_coords ;
end
