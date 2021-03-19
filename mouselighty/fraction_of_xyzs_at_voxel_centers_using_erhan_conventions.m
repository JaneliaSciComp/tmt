function result = fraction_of_xyzs_at_voxel_centers_using_erhan_conventions(xyzs, spacing, origin)
    % Returns the fraction of points at voxel centers.  Assumes that origin is
    % the location of the *corner* of the voxel with lowest-possible indices.
    % This is the convention used by Erhan in the fragment-generation code.
    %
    % xyzs should be node_count x 3, in um, and in xyz order
    % spacing is 1 x 3, in um
    % origin is 1 x 3, in um (It's the Erhan origin, which is a little
    % different from the JaWS origin)
    ijk1s_unrounded = (xyzs - origin) ./ spacing + 0.5 ;   % one-based voxel indices
    ijk1s = round(ijk1s_unrounded) ;
    node_offsets = ijk1s_unrounded - ijk1s ;
    absolute_node_offsets = abs(node_offsets) ;
    is_at_voxel_center_from_neuron_index = all( absolute_node_offsets < 0.001, 2 ) ;  % the offsets should just be floating-point error
    result = mean( is_at_voxel_center_from_neuron_index ) ;
end
