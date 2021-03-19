function forest = load_forest_from_folder_of_named_tree_mats(input_folder_path)
    if ~exist(input_folder_path, 'file') ,
        error('Folder %s does not exist', input_folder_path) ;
    end
    full_tree_file_names = simple_dir(fullfile(input_folder_path, 'auto-cc-*.mat')) ;
    full_tress_to_process_count = length(full_tree_file_names) ;

    fprintf('Starting the big parfor loop, going to load %d full trees...\n', full_tress_to_process_count) ;
    forest = empty_named_tree_struct(full_tress_to_process_count, 1) ;    
    parfor_progress(full_tress_to_process_count) ;
    parfor full_tree_index = 1 : full_tress_to_process_count ,
        full_tree_file_name = full_tree_file_names{full_tree_index} ;
        full_tree_mat_file_path = fullfile(input_folder_path, full_tree_file_name) ;
        mat_contents = load('-mat', full_tree_mat_file_path) ;
        named_tree = mat_contents.named_tree ;
        forest(full_tree_index) = named_tree ;        
        % Update the progress bar
        parfor_progress() ;
    end
    parfor_progress(0) ;
end
