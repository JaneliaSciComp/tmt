function generate_fragments(input_folder_path, ...
                            output_folder_path, ...
                            maximum_core_count_desired, ...
                            minimum_centerpoint_count_per_fragment, ...
                            bounding_box_low_corner_xyz, ...
                            bounding_box_high_corner_xyz)
    
    % Get the pool ready
    use_this_many_cores(maximum_core_count_desired) ;
    
    if ~exist(output_folder_path, 'dir') ,
        mkdir(output_folder_path) ;
    end
    mat_output_folder_path = fullfile(output_folder_path, 'as-mats') ;
    if ~exist(mat_output_folder_path, 'dir') ,
        mkdir(mat_output_folder_path) ;
    end
    swc_output_folder_path = fullfile(output_folder_path, 'as-swcs') ;
    if ~exist(swc_output_folder_path, 'dir') ,
        mkdir(swc_output_folder_path) ;
    end    
    
    full_tree_file_names = simple_dir(fullfile(input_folder_path, 'auto-cc-*.mat')) ;
    full_trees_to_process_count = length(full_tree_file_names) ;
    %tic_id = tic() ;
    fprintf('Starting the fragment generation outer for loop, going to process %d full trees...\n', full_trees_to_process_count) ;
    %parfor_progress(full_trees_to_process_count) ;
    pbo = progress_bar_object(full_trees_to_process_count) ;
    for full_tree_index = 1 : full_trees_to_process_count ,
    %for full_tree_index = full_trees_to_process_count : -1 : 1 ,  % good for debugging, process small ones first to make sure loop body runs
        full_tree_file_name = full_tree_file_names{full_tree_index} ;
        full_tree_mat_file_path = fullfile(input_folder_path, full_tree_file_name) ;
        named_tree = load_named_tree_from_mat(full_tree_mat_file_path) ;
        generate_fragments_from_named_tree(mat_output_folder_path, ...
                                           swc_output_folder_path, ...
                                           named_tree, ...
                                           minimum_centerpoint_count_per_fragment, ...
                                           bounding_box_low_corner_xyz, ...
                                           bounding_box_high_corner_xyz) ;
        
        % Update the progress bar
        pbo.update(full_tree_index) ;
        %parfor_progress() ;
    end
    pbo.finish_up() ;    
    %parfor_progress(0) ;
    %toc(tic_id) ;
end
