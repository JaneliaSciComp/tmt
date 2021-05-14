function result = montage_from_stack_ijk(stack_ijk)  % the _ijk here means "in xyz order, but the coords are integers"
    % rearrange the z-slices of a stack into a montage for easy visualization
    [n_i, n_j, n_k] = size(stack_ijk) ;
    column_count = round(sqrt(n_k)) ;  % the number of tiles in each row of the montage
    row_count = ceil(n_k/column_count) ;  % the number of tiles in each column of the montage
    result = zeros([row_count*n_j column_count*n_i], class(stack_ijk)) ;
    i_k = 1 ;
    for row_index = 1 : row_count ,
        i_tile_offset = (row_index-1) * n_j ;  % this is an i in the conventional sense, i.e. a row index
        for column_index = 1 : column_count ,
            if i_k <= n_k ,
                j_tile_offset = (column_index-1) * n_i ;  % this is a j in the conventional sense, i.e. a column index
                tile_ij = stack_ijk(:,:,i_k) ;
                tile_ji = tile_ij' ;  % transpose for proper visualization
                result(i_tile_offset+1:i_tile_offset+n_j, j_tile_offset+1:j_tile_offset+n_i) = tile_ji ; 
                i_k = i_k + 1 ;
            end
        end
    end
end
