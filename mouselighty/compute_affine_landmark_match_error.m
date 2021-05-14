function match_sse_from_neighbor_index_from_tile_index = ...
        compute_affine_landmark_match_error(self_ijk0_from_match_index_from_neighbor_index_from_tile_index, ...
                                            has_neighbor_from_neighbor_index_from_tile_index, ...
                                            neighbor_tile_index_from_neighbor_index_from_tile_index, ...
                                            neighbor_ijk0_from_match_idx_from_neighbor_idx_from_tile_idx, ...
                                            affine_transform_from_tile_index)
                                        
   % Compute the positional error for matched landmarks between tiles.  If
   % affine stitching was perfect, this error would be zero everywhere.  The
   % returned SSE has units of um^2.  We assume the matches are organized with the
   % x+1, y+1, and z+1 given for each tile.  If there's no such neighbor, 
   % neighbor_tile_index_from_neighbor_index_from_tile_index should be nan for that
   % element.
   
   tile_count = length(self_ijk0_from_match_index_from_neighbor_index_from_tile_index) ;
   neighbor_count = 3 ;
   %match_count_from_neighbor_index_from_tile_index = zeros(neighbor_count, tile_count) ;
   match_sse_from_neighbor_index_from_tile_index = nan(neighbor_count, tile_count) ;
   for tile_index = 1 : tile_count ,
       self_ijk0_from_match_index_from_neighbor_index = self_ijk0_from_match_index_from_neighbor_index_from_tile_index(:,tile_index) ;
       neighbor_tile_index_from_neighbor_index = neighbor_tile_index_from_neighbor_index_from_tile_index(:,tile_index) ;
       neighbor_ijk0_from_match_index_from_neighbor_index = neighbor_ijk0_from_match_idx_from_neighbor_idx_from_tile_idx(:,tile_index) ;
       self_affine_transform = affine_transform_from_tile_index(:,:,tile_index) ;
       has_neighbor_from_neighbor_index = has_neighbor_from_neighbor_index_from_tile_index(:, tile_index) ;
       for neighbor_index = 1 : neighbor_count ,
           has_neighbor = has_neighbor_from_neighbor_index(neighbor_index) ;
           if has_neighbor ,
               neighbor_tile_index = neighbor_tile_index_from_neighbor_index(neighbor_index) ;
               self_ijk0_from_match_index = self_ijk0_from_match_index_from_neighbor_index{neighbor_index} ;
               neighbor_affine_transform = affine_transform_from_tile_index(:,:,neighbor_tile_index) ;           
               neighbor_ijk0_from_match_index = neighbor_ijk0_from_match_index_from_neighbor_index{neighbor_index} ;
               self_xyz_from_match_index = add_ones_column(self_ijk0_from_match_index) * self_affine_transform' ;  % um, in rendered space
               neighbor_xyz_from_match_index = add_ones_column(neighbor_ijk0_from_match_index) * neighbor_affine_transform' ;  % um, in rendered space
               dxyz_from_match_index = neighbor_xyz_from_match_index - self_xyz_from_match_index ;
               squared_error_from_match_index = sum(dxyz_from_match_index.^2, 2) ;
               %match_count = length(squared_error_from_match_index) ;
               sse = sum(squared_error_from_match_index) ;
               % store stuff for this neighbor, tile
               %match_count_from_neighbor_index_from_tile_index(neighbor_index, tile_index) = match_count ;
               match_sse_from_neighbor_index_from_tile_index(neighbor_index, tile_index) = sse ;
           end
       end
   end
end
