function result = landmark_file_name_from_tile_relative_path(tile_relative_path, channel_index0)
    [~,tile_day_index_as_string] = fileparts2(tile_relative_path) ;
    if ischar(channel_index0) ,
        result = sprintf('%s-desc.%s.txt', tile_day_index_as_string, channel_index0) ;
    else
        result = sprintf('%s-desc.%d.txt', tile_day_index_as_string, channel_index0) ;
    end
end
