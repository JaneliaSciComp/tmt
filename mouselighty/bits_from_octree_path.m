function bits = bits_from_octree_path(octree_path)
    % octree_path is 1 x zoom_level, with each element giving the
    % morton-ordered octant for each level of the octree.
    %
    % bits is zoom_level x 3, with cols in xyz order
    %
    % morton_octant_index = 1 + x_bit + 2*y_bit + 4*z_bit
    %
    % For each column of bits, each element gives whether the chunk is in
    % the bottom half (0) or top half(1) of the octree at that level.
    % result is 1 x zoom_level, which each element giving the
    % morton-ordered octant for each level of the octree. i.e.
    % morton_octant_index = 1 + x_bit + 2*y_bit + 4*z_bit
    
    octree_path_0 = octree_path - 1 ;  % morton on on [0,7]
    bits = bsxfun(@bitget, octree_path_0', 1:3) ;
end
