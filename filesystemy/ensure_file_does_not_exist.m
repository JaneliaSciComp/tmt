function ensure_file_does_not_exist(raw_file_path)
    file_path = absolute_filename(raw_file_path) ;
    if exist(file_path, 'file') ,
        system_from_list_with_error_handling({'rm', '-rf', file_path}) ;
    end
end
