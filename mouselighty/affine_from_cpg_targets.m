function result = affine_from_cpg_targets(cpg_i0_values , ...
                                          cpg_j0_values , ...
                                          cpg_k0_values , ...
                                          xyz_from_grid_index) 
    [i0_from_grid_coords, j0_from_grid_coords, k0_from_grid_coords] = ndgrid(cpg_i0_values, cpg_j0_values, cpg_k0_values) ;
    ijk0_from_grid_index = [i0_from_grid_coords(:) j0_from_grid_coords(:) k0_from_grid_coords(:)]' ;
    X_aug = add_ones_row(xyz_from_grid_index') ;
    r_aug = add_ones_row(ijk0_from_grid_index) ;
    A = X_aug/r_aug ;  % 4x4, Compute a single transform that approximates, as best it can, the mapping implied by all the control-point to target pairs.
    result = A(1:3,:) ;
end
