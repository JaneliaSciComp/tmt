function distance_from_match_index_from_neighbor_index_from_tile_index = ...
        compute_affine_landmark_match_distance(self_ijk0_from_match_index_from_neighbor_index_from_tile_index, ...
                                               has_neighbor_from_neighbor_index_from_tile_index, ...
                                               neighbor_tile_index_from_neighbor_index_from_tile_index, ...
                                               neighbor_ijk0_from_match_idx_from_neighbor_idx_from_tile_idx, ...
                                               affine_transform_from_tile_index)
                                        
   % Compute the positional distance for matched landmarks between tiles.  If
   % affine stitching was perfect, this error would be zero everywhere.  The
   % returned distances have units of um.  We assume the matches are organized with the
   % x+1, y+1, and z+1 given for each tile.
   % Output is a 3 x tile_count cell array, with each element a column vector of
   % distances, one per match.
   
   tile_count = length(self_ijk0_from_match_index_from_neighbor_index_from_tile_index) ;
   neighbor_count = 3 ;
   distance_from_match_index_from_neighbor_index_from_tile_index = cell(neighbor_count, tile_count) ;
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
               dxyz_from_match_index = neighbor_xyz_from_match_index - self_xyz_from_match_index ;  % match_count x 3
               distance_from_match_index = vecnorm(dxyz_from_match_index, 2, 2) ; % match_count x 1
               distance_from_match_index_from_neighbor_index_from_tile_index{neighbor_index, tile_index} = distance_from_match_index ;
           else
               distance_from_match_index_from_neighbor_index_from_tile_index{neighbor_index, tile_index} = zeros(0,1) ;  % want col vector               
           end
       end
   end
end
