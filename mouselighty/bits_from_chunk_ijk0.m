function bits = bits_from_chunk_ijk0(chunk_ijk0, zoom_level)
    % chunk_ijk0 is 1 x 3
    % zoom_level is the number of octal digits needs to specify a leaf at
    % the current zoom level.  So zoom_level 0 means there's only one leaf,
    % zoom_level 1 means there's 8^1 leaves, zoom level n means theres 8^n
    % leaves.
    % bits is zoom_level x 3, columns correspond to xyz.
    % For each column, each element gives whether the chunk is in the
    % bottom half (0) or top half(1) of the octree at that level, in that
    % dimension.
    bits = zeros(zoom_level, 3) ;
    for j = 1:3 ,
        n = chunk_ijk0(j) ;
        n_in_binary = bitget(n, zoom_level:-1:1) ;
        bits(:,j) = n_in_binary' ;
    end
%     for i = 1:level_step_count ,
%         n = level_step_count-i ;  % e.g. if level_step_count is 6, then n goes from 5 down to 0
%         halfway_index_at_this_level = (2^n) ;
%         bits_at_this_level = (chunk_ijk0_remnant>=halfway_index_at_this_level) ;
%         bits(i, :) = bits_at_this_level ;
%         chunk_ijk0_remnant = chunk_ijk0_remnant - halfway_index_at_this_level .* bits_at_this_level ;
%     end
end
