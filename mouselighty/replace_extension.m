function result = replace_extension(file_name, new_extension)
    % Replace the extension of the given file_name with the new_extension
    [path_to_parent, base_name, ~] = fileparts(file_name) ;
    result = fullfile(path_to_parent, horzcat(base_name, new_extension)) ;
end
