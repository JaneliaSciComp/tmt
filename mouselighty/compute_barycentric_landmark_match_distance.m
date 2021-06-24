function [distance_from_match_index_from_neighbor_index_from_tile_index, is_within_cpg_from_match_idx_from_neighbor_idx_from_tile_idx] = ...
        compute_barycentric_landmark_match_distance(self_ijk0_from_match_index_from_neighbor_index_from_tile_index, ...
                                                    has_neighbor_from_neighbor_index_from_tile_index, ...
                                                    neighbor_tile_index_from_neighbor_index_from_tile_index, ...
                                                    neighbor_ijk0_from_match_idx_from_neighbor_idx_from_tile_idx, ...
                                                    cpg_i0_values , ...
                                                    cpg_j0_values , ...
                                                    cpg_k0_values_from_tile_index , ...
                                                    targets_from_tile_index)
                                        
   % Compute the position error distance for matched landmarks between tiles.  If
   % stitching was perfect, this error would be zero everywhere.  The
   % returned distances have units of um.  We assume the matches are organized with the
   % x+1, y+1, and z+1 given for each tile.
   % Output is a 3 x tile_count cell array, with each element a column vector of
   % distances, one per match.  If the landmark is outside the control point grid for each tile,
   % the distance will be given as nan.
   % is_within_cpg_from_match_idx_from_neighbor_idx_from_tile_idx is true for
   % elements of distance_from_match_index_from_neighbor_index_from_tile_index for
   % which matched landmarks are both within the control point grid.
   
   tile_count = length(self_ijk0_from_match_index_from_neighbor_index_from_tile_index) ;
   neighbor_count = 3 ;
   distance_from_match_index_from_neighbor_index_from_tile_index = cell(neighbor_count, tile_count) ;   
   is_within_cpg_from_match_idx_from_neighbor_idx_from_tile_idx = cell(neighbor_count, tile_count) ;   
   for tile_index = 1 : tile_count ,
       self_ijk0_from_match_index_from_neighbor_index = self_ijk0_from_match_index_from_neighbor_index_from_tile_index(:,tile_index) ;
       neighbor_tile_index_from_neighbor_index = neighbor_tile_index_from_neighbor_index_from_tile_index(:,tile_index) ;
       neighbor_ijk0_from_match_index_from_neighbor_index = neighbor_ijk0_from_match_idx_from_neighbor_idx_from_tile_idx(:,tile_index) ;
       %self_affine_transform = affine_transform_from_tile_index(:,:,tile_index) 
       self_cpg_k0_values = cpg_k0_values_from_tile_index(:,tile_index)' ;
       self_targets = targets_from_tile_index(:,:,tile_index) ;
       self_barycentric_interpolator = ...
           barycentric_interpolant(cpg_i0_values , ...
                                   cpg_j0_values , ...
                                   self_cpg_k0_values , ...
                                   self_targets) ;
%        check_self_affine_transform = ...
%            affine_from_cpg_targets(cpg_i0_values , ...
%                                    cpg_j0_values , ...
%                                    self_cpg_k0_values , ...
%                                    self_targets)                                
       has_neighbor_from_neighbor_index = has_neighbor_from_neighbor_index_from_tile_index(:, tile_index) ;
       for neighbor_index = 1 : neighbor_count ,
           has_neighbor = has_neighbor_from_neighbor_index(neighbor_index) ;
           if has_neighbor ,
               neighbor_tile_index = neighbor_tile_index_from_neighbor_index(neighbor_index) ;
               self_ijk0_from_match_index = self_ijk0_from_match_index_from_neighbor_index{neighbor_index} ;
               %neighbor_affine_transform = affine_transform_from_tile_index(:,:,neighbor_tile_index) ;           
               neighbor_cpg_k0_values = cpg_k0_values_from_tile_index(:,neighbor_tile_index)' ;
               neighbor_targets = targets_from_tile_index(:,:,neighbor_tile_index) ;
               neighbor_barycentric_interpolator = ...
                   barycentric_interpolant(cpg_i0_values , ...
                                           cpg_j0_values , ...
                                           neighbor_cpg_k0_values , ...
                                           neighbor_targets) ;
               neighbor_ijk0_from_match_index = neighbor_ijk0_from_match_index_from_neighbor_index{neighbor_index} ;
               %affine_self_xyz_from_match_index = add_ones_column(self_ijk0_from_match_index) * self_affine_transform' ;  % um, in rendered space
               self_xyz_from_match_index = self_barycentric_interpolator(self_ijk0_from_match_index) ;  % um, in rendered space
               %affine_neighbor_xyz_from_match_index = add_ones_column(neighbor_ijk0_from_match_index) * neighbor_affine_transform' ;  % um, in rendered space
               neighbor_xyz_from_match_index = neighbor_barycentric_interpolator(neighbor_ijk0_from_match_index) ;  % um, in rendered space
               dxyz_from_match_index = neighbor_xyz_from_match_index - self_xyz_from_match_index ;
               distance_from_match_index = vecnorm(dxyz_from_match_index, 2, 2) ; % match_count x 1
               is_within_cpg = ~isnan(distance_from_match_index) ;
               distance_from_match_index(~is_within_cpg) = 0 ;  % set the nans to zero, makes life easier when doing SSE, etc
               distance_from_match_index_from_neighbor_index_from_tile_index{neighbor_index, tile_index} = distance_from_match_index ;
               is_within_cpg_from_match_idx_from_neighbor_idx_from_tile_idx{neighbor_index, tile_index} = is_within_cpg ;
           else
               distance_from_match_index_from_neighbor_index_from_tile_index{neighbor_index, tile_index} = zeros(0,1) ;  % want col vector
               is_within_cpg_from_match_idx_from_neighbor_idx_from_tile_idx{neighbor_index, tile_index} = false(0,1) ;               
           end
       end
   end
end
