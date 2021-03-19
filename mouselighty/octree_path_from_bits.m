function result = octree_path_from_bits(bits)
    % bits is level_step_count x 3, and each element is 0 or 1
    % The three columns are x, y, z
    % For each column, each element gives whether the chunk is in the
    % bottom half (0) or top half(1) of the octree at that level.
    % result is 1 x zoom_level, which each element giving the
    % morton-ordered octant for each level of the octree.
    % i.e. morton_octant_index = 1 + x_bit + 2*y_bit + 4*z_bit
    result = (1 + sum(bits .* [1 2 4], 2))' ;
end
