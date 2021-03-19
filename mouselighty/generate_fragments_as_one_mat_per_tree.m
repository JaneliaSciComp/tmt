function generate_fragments_as_one_mat_per_tree(input_folder_path, ...
                                                output_folder_path, ...
                                                maximum_core_count_desired, ...
                                                minimum_centerpoint_count_per_fragment, ...
                                                bounding_box_low_corner_xyz, ...
                                                bounding_box_high_corner_xyz)
    
    use_this_many_cores(maximum_core_count_desired) ;    
    if ~exist(output_folder_path, 'dir') ,
        mkdir(output_folder_path) ;
    end
    full_tree_file_names = simple_dir(fullfile(input_folder_path, 'auto-cc-*.mat')) ;
    full_trees_to_process_count = length(full_tree_file_names) ;
    tic_id = tic() ;
    fprintf('Starting the big parfor loop, going to process %d full trees...\n', full_trees_to_process_count) ;
    parfor_progress(full_trees_to_process_count) ;
    parfor full_tree_index = 1 : full_trees_to_process_count ,
        full_tree_file_name = full_tree_file_names{full_tree_index} ;
        full_tree_mat_file_path = fullfile(input_folder_path, full_tree_file_name) ;
        named_tree = load_named_tree_from_mat(full_tree_mat_file_path) ;
        write_fragments_as_mats_given_named_tree(output_folder_path, ...
                                                 named_tree, ...
                                                 minimum_centerpoint_count_per_fragment, ...
                                                 bounding_box_low_corner_xyz, ...
                                                 bounding_box_high_corner_xyz) ;
        
        % Update the progress bar
        parfor_progress() ;
    end
    parfor_progress(0) ;
    toc(tic_id) ;
end
