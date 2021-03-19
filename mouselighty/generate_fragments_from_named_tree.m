function generate_fragments_from_named_tree(mat_output_folder_path, ...
                                            swc_output_folder_path, ...
                                            named_tree, ...
                                            minimum_centerpoint_count_per_fragment, ...
                                            bounding_box_low_corner_xyz, ...
                                            bounding_box_high_corner_xyz)
                                        
    % Generate the file name for the mat file
    fragments_mat_file_name = sprintf('%s-fragments.mat', named_tree.name) ;
    fragments_mat_file_path = fullfile(mat_output_folder_path, fragments_mat_file_name);
    
    % Break the tree into fragments, in main memory
    fragments_as_named_trees = ...
        named_forest_of_fragments_from_named_tree(named_tree, ...
                                                  minimum_centerpoint_count_per_fragment, ...
                                                  bounding_box_low_corner_xyz, ...
                                                  bounding_box_high_corner_xyz) ;    

    % Save these fragments to a mat file
    if ~exist(fragments_mat_file_path, 'file') ,
        save(fragments_mat_file_path, '-v7.3', 'fragments_as_named_trees') ;
    end
                                   
    % Output the per-fragment .swc's
    fragment_count = length(fragments_as_named_trees) ;    
    parfor fragment_index = 1:fragment_count ,
        fragment_as_named_tree = fragments_as_named_trees(fragment_index) ;

        % .swc file name
        fragment_name = fragment_as_named_tree.name ;
        fragment_swc_file_name = sprintf('%s.swc', fragment_name) ;
        fragment_swc_file_path = fullfile(swc_output_folder_path, fragment_swc_file_name);

        % If the output file already exists, skip it
        if exist(fragment_swc_file_path, 'file') ,
            continue 
        end       

        % Save the fragment to a .swc file
        save_named_tree(fragment_swc_file_path, fragment_as_named_tree) ;        
    end    
end
