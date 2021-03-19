function octree_paths = octree_paths_from_chunk_ijk1s(chunk_ijk1s, zoom_level)
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
    
    chunk_ijk0s = chunk_ijk1s - 1 ;
    row_count = size(chunk_ijk1s, 1) ;
    octree_paths = zeros(row_count, zoom_level) ;
    for idx =  1:row_count ,
        chunk_ijk0_this = chunk_ijk0s(idx,:) ;
        bits = bits_from_chunk_ijk0(chunk_ijk0_this, zoom_level) ;        
        % Convert to octant code for each coordinate
        octree_paths(idx,:) = octree_path_from_bits(bits) ;
    end
end



