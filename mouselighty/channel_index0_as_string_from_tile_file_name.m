function result = channel_index0_as_string_from_tile_file_name(tile_file_name)
    % E.g. '00034-ngc.0.tif' -> '0', '00042-prob.1.h5' -> '1'
    tile_base_name =base_name_from_file_name(tile_file_name) ;
    dot_indices = strfind(tile_base_name, '.') ;
    if isempty(dot_indices) ,
        error('Tile file name %s does not conform to MouseLight conventions', tile_file_name) ;
    end
    last_dot_index = dot_indices(end) ;
    if last_dot_index == length(tile_base_name) ,
        error('Tile file name %s does not conform to MouseLight conventions', tile_file_name) ;
    end        
    result = tile_base_name(last_dot_index+1:end) ;    
end
