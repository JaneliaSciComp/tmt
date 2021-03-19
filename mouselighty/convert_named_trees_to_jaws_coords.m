function result = convert_named_trees_to_jaws_coords(named_trees_in_erhan_coords, origin, spacing, jaws_origin)
    % origin is 3x1, in um, is the erhan-style origin (the outside corner of the
    % low-index corner voxel)
    % spacing is 3x1, is the voxel spacing in um
    % jaws_origin is 3x1, in um, is the jaws-style origin (the center of the
    % low-index corner voxel)
    % everything in xyz order 
    result = arrayfun(@(named_tree_in_erhan_coords)(convert_named_tree_to_jaws_coords(named_tree_in_erhan_coords, origin, spacing, jaws_origin)), ...
                      named_trees_in_erhan_coords, ...
                      'UniformOutput', true) ;
end
