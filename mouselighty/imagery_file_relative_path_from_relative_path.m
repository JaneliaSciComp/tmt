function result = imagery_file_relative_path_from_relative_path(relative_path, channel_index, extension) 
    % E.g. '2020-12-01/01/01916' -> '2020-12-01/01/01916/01916-ngc.0.tif'
    if ~exist('extension', 'var') || isempty(extension) ,
        extension = '.tif' ;
    end    
    [~, leaf_folder_name] = fileparts2(relative_path) ;
    imagery_file_name = sprintf('%s-ngc.%d%s', leaf_folder_name, channel_index, extension) ;
    result = fullfile(relative_path, imagery_file_name) ;
end
