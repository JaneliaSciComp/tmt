function collect_fragments_into_single_mat_file(sample_date)    
    fprintf('\n\n\nCollecting fragments into single .mat file...\n') ;
    outer_tic_id = tic() ;
    
    input_folder_path = ...
        sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s/build-brain-output/frags-with-5-or-more-nodes/as-mats', sample_date) ;
    output_file_path = ...
        sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s/build-brain-output/frags-with-5-or-more-nodes.mat', sample_date) ;

    % Get the pool ready
    use_this_fraction_of_cores(1) ;

    frag_mat_file_names = simple_dir(fullfile(input_folder_path, 'auto-cc-*-fragments.mat')) ;
    tree_count = length(frag_mat_file_names) ;
    fragments_from_tree_id = cell(1, tree_count) ;
    %tic_id = tic() ;
    parfor_progress(tree_count) ;
    parfor tree_index = 1 : tree_count ,
        frag_mat_file_name = frag_mat_file_names{tree_index} ;
        frag_mat_file_path = fullfile(input_folder_path, frag_mat_file_name) ;
        fragments_from_tree_id{tree_index} = load_anonymous(frag_mat_file_path) ;
        parfor_progress() ;
    end
    parfor_progress(0) ;
    %elapsed_time = toc(tic_id) ;
    %fprintf('Elapsed time to read in all fragment .mats was %g seconds\n', elapsed_time) ;

    fragments_as_swc_arrays = horzcat(fragments_from_tree_id{:}) ;  

    save(output_file_path, 'fragments_as_swc_arrays', '-v7.3', '-nocompression') ;
    
    elapsed_time = toc(outer_tic_id) ;
    fprintf('Done collecting fragments into a single .mat file.  Elapsed time: %g\n', elapsed_time) ;
end
