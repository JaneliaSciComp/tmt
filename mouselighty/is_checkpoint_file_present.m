function result = is_checkpoint_file_present(file_path, n)
    checkpoint_file_name = horzcat(file_path, sprintf('.checkpoint-%d', n)) ;
    result = logical(exist(checkpoint_file_name, 'file')) ;
end
