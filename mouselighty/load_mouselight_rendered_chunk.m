function stack = load_mouselight_rendered_chunk(rendered_folder_name, chunk_path, channel_index)
    chunk_path_as_string = file_path_from_chunk_path(chunk_path) ;
    chunk_folder_name = fullfile(rendered_folder_name, chunk_path_as_string) ;
    chunk_file_leaf_name = sprintf('default.%d.tif', channel_index) ;
    chunk_file_name = fullfile(chunk_folder_name, chunk_file_leaf_name) ;
    if exist(chunk_file_name, 'file') ,
        stack = read_16bit_grayscale_tif(chunk_file_name) ;
    else
        error('mouselight:no_such_rendered_chunk', ...
              'No rendered chunk at %s', chunk_file_name) ;
    end
end
