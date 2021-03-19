function result = file_path_from_chunk_path(chunk_path) 
    result_with_trailing_slash = sprintf('%d/', chunk_path) ;
    result = result_with_trailing_slash(1:end-1) ;
end