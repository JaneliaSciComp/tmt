function named_tree = load_named_tree_from_mat(named_tree_mat_file_path)
    load(named_tree_mat_file_path, '-mat', 'named_tree') ;
    if ~exist('named_tree', 'var') ,
        error('File %s is missing variable named_tree', named_tree_mat_file_path) ;
    end
end
