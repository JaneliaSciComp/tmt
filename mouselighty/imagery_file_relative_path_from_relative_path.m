function result = imagery_file_relative_path_from_relative_path(relative_path, channel_index) 
    % E.g. '2020-12-01/01/01916' -> '2020-12-01/01/01916/01916-ngc.0.tif'
    [~, leaf_folder_name] = fileparts2(relative_path) ;
    imagery_file_name = sprintf('%s-ngc.%d.tif', leaf_folder_name, channel_index) ;
    result = fullfile(relative_path, imagery_file_name) ;
end
