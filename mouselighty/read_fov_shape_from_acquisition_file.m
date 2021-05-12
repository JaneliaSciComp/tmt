function tile_fov_shape_um_xyz = read_fov_shape_from_acquisition_file(acquisition_file_name)
    % Reads the shape, in um, of a single tile from a tile's acquisiton file.
    % This will be the same across all tiles in a sample unless something has gone
    % horribly wrong.
    %
    % Note that tile_fov_shape_xyz uses the convention that 
    %
    %   inter_voxel_spacing = tile_fov_shape_xyz ./ (tile_shape_ijk-1)
    %
    % 
    
    % Read the file in, convert to tokens
    file_text = fileread(acquisition_file_name) ;
    file_text_without_colons = strrep(file_text, ':', '') ;  % remove the colons, since we don't need them
    tokens = strsplit(file_text_without_colons) ;
    
    % Get the FOV values
    tile_fov_shape_um_x = find_label_and_get_value_in_acquisition_file(tokens, 'fov_x_size_um') ;
    tile_fov_shape_um_y = find_label_and_get_value_in_acquisition_file(tokens, 'fov_y_size_um') ;
    tile_fov_shape_um_z = find_label_and_get_value_in_acquisition_file(tokens, 'fov_z_size_um') ;    
    tile_fov_shape_um_xyz = [tile_fov_shape_um_x tile_fov_shape_um_y tile_fov_shape_um_z] ;
end
