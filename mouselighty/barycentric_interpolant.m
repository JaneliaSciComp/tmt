function result = ...
        barycentric_interpolant(cpg_i0_values , ...
                                cpg_j0_values , ...
                                cpg_k0_values , ...
                                xyz_from_grid_index)
    % "CPG" stands for "control point grid".  It's the grid of input points that we
    % use to constuct the interpolator.
    % cpg_i0_values: row vector of x/i values in the CPG
    % cpg_j0_values: row vector of y/j values in the CPG
    % cpg_k0_values: row vector of z/k values in the CPG
    % xyz_from_grid_index: For each point on the CPG, the point in 3-space that
    %   it should be mapped to, grid_count x 3, where grid_count is the product of
    %   the lengths of cpg_i0_values, cpg_j0_values, and cpg_k0_values.  These must
    %   be in "z-major" order.  I.e. x coord changes most quickly, y next, then z.
    %
    % Output:
    %   An interpolating function that maps from input ijk0 triples to xyz triples.
    
    % Enumerate all the grid ijk0 points, in z-major order to match xyz_from_grid_index
    [cpg_i0_grid, cpg_j0_grid, cpg_k0_grid] = ndgrid(cpg_i0_values, cpg_j0_values, cpg_k0_values) ;
    i0_from_grid_index = cpg_i0_grid(:) ;
    j0_from_grid_index = cpg_j0_grid(:) ;
    k0_from_grid_index = cpg_k0_grid(:) ;
    ijk0_from_grid_index = horzcat(i0_from_grid_index, j0_from_grid_index, k0_from_grid_index) ;  % grid_count x 3
     
    % Make a scattered interpolator for each output dimension.
    % The 'linear' option will make these barycentric interpolators
    % The 'none' will make them not do any extrapolation
    x_from_grid_index = xyz_from_grid_index(:,1) ;
    y_from_grid_index = xyz_from_grid_index(:,2) ;
    z_from_grid_index = xyz_from_grid_index(:,3) ;
    x_from_query_ijk0 = scatteredInterpolant(ijk0_from_grid_index, x_from_grid_index, 'linear', 'none') ;
    y_from_query_ijk0 = scatteredInterpolant(ijk0_from_grid_index, y_from_grid_index, 'linear', 'none') ;
    z_from_query_ijk0 = scatteredInterpolant(ijk0_from_grid_index, z_from_grid_index, 'linear', 'none') ;

    % Construct a closure that can be used to do the interpolation
    function xyz_from_query_index = closure(ijk0_from_query_index) 
        % ijk0_from_query_index, the x/i, y/j, and z/k coords of each query point to be fed
        %   into the interpolator. query_count x 3
        % Output:
        %   xyz_from_query_index, the output xyz point for each query.  query_count x 3
        
        % Apply each interpolator to each query point
        x_from_query_index = x_from_query_ijk0(ijk0_from_query_index) ;
        y_from_query_index = y_from_query_ijk0(ijk0_from_query_index) ;
        z_from_query_index = z_from_query_ijk0(ijk0_from_query_index) ;
        
        % Collect the results into a single query_count x 3 matrix
        xyz_from_query_index = horzcat(x_from_query_index, y_from_query_index, z_from_query_index) ;
    end

    % Test the closure
    interpolated_xyz_from_grid_index = closure(ijk0_from_grid_index) ;
    if max(max(abs(interpolated_xyz_from_grid_index-xyz_from_grid_index))) > 0.001 ,
        error('Interpolator is no good.') ;
    end
    
    % Return the closure
    result = @closure ;
end
