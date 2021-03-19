function chunk_ijk0 = chunk_ijk0_from_bits(bits)
    % bits is zoom_level x 3, columns correspond to xyz.
    % For each column, each element gives whether the chunk is in the
    % bottom half (0) or top half(1) of the octree at that level, in that
    % dimension.
    %
    % chunk_ijk0 is 1 x 3
    %
    % zoom_level is the number of octal digits needs to specify a leaf at
    % the current zoom level.  So zoom_level 0 means there's only one leaf,
    % zoom_level 1 means there's 8^1 leaves, zoom level n means theres 8^n
    % leaves.
    zoom_level = size(bits, 1) ;
    magnifier = 2 .^ ((zoom_level-1):-1:0)' ;  % col vector
    chunk_ijk0 = sum(magnifier .* bits, 1) ;
end
