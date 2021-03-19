function chunk_ijk1s = chunk_ijk1s_from_octree_paths(octree_paths)
    % An 'octree' with at least zoom-level+1 levels of resolution will have 8^zoom_level chunks at
    % zoom level zoom_level.  (Meaning the level at which it requires
    % zoom_level octal digits to uniquely specify a chunk.)
    % This function converts from chunk coordinates chunk_ijk1s
    % to the corresponding octree paths.
    %
    % Here, by "the coordinates of a chunk", we mean: Taking the full stack
    % to consist of a 2^zoom_level x 2^zoom_level x 2^zoom_level array of
    % chunks, the coordinate of a chunks is the 1 x 3 array of integers
    % specifying the location of the chunk in each dimension.
    %
    % Each row of chunk_ijk1s should be 1 x 3, giving the coordinates of a
    % chunk in xyz order, using one-based indexing.  Thus each element of
    % chunk_ijk1s should be an integer on [1, 2^zoom_level].
    %
    % On output, each row has zoom_level elements, and gives the octree
    % path to the chunk, as a sequence of morton-coded octants.
    
    [row_count, ~] = size(octree_paths) ;
    chunk_ijk0s = zeros(row_count, 3) ;
    for idx =  1:row_count ,
        octree_path = octree_paths(idx,:) ;
        bits = bits_from_octree_path(octree_path) ;        
        chunk_ijk0s(idx,:) = chunk_ijk0_from_bits(bits) ;
    end
    chunk_ijk1s = chunk_ijk0s + 1 ;
end
