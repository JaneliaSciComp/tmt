function convert_full_named_trees_as_mat_to_swc(trees_as_swc_folder_path, trees_as_mat_folder_path)
    tic_id = tic() ;
    if ~exist(trees_as_swc_folder_path, 'file') ,
        mkdir(trees_as_swc_folder_path) ;
    end
    mat_file_names = simple_dir(fullfile(trees_as_mat_folder_path, 'auto*.mat')) ;
    file_count = length(mat_file_names) ;
        
    fprintf('Converting %d trees as .mat to .swc...\n', file_count) ;
    parfor_progress(file_count) ;
    parfor i = 1 : file_count ,
        mat_file_name = mat_file_names{i} ;
        swc_base_name = base_name_from_file_name(mat_file_name) ;
        swc_file_name = horzcat(swc_base_name, '.swc') ;
        swc_file_path = fullfile(trees_as_swc_folder_path, swc_file_name) ;
        if ~exist(swc_file_path, 'file') ,
            mat_file_path = fullfile(trees_as_mat_folder_path, mat_file_name) ;
            mat_contents = load('-mat', mat_file_path) ;
            named_tree = mat_contents.named_tree ;
            save_named_tree_as_swc(swc_file_path, named_tree) ;
        end
        parfor_progress() ;
    end
    parfor_progress(0) ;
    elapsed_time = toc(tic_id) ;
    fprintf('Elapsed time for convert_full_named_trees_as_mat_to_swc() was %g seconds\n', elapsed_time) ;
end
