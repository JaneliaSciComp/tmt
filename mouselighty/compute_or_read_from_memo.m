function result = compute_or_read_from_memo(cache_folder_path, ...
                                            memo_base_name, ...
                                            compute_function, ...
                                            do_force_computation) 
    % A function to help with the common pattern of wanting to cache expensive-to-compute quantities on disk                                    
    if ~exist('do_force_computation', 'var') || isempty(do_force_computation) ,
        do_force_computation = false ;
    end
    memo_file_name = horzcat(memo_base_name, '.mat') ;
    memo_file_path = fullfile(cache_folder_path, memo_file_name) ;
    if do_force_computation ,
        if exist(memo_file_path, 'file') ,
            delete(memo_file_path) ;
        end
    end
    if exist(cache_folder_path, 'file') ,
        if exist(memo_file_path, 'file') ,        
            load(memo_file_path, 'result') ;
        else
            result = feval(compute_function) ;
            save(memo_file_path, '-mat', '-v7.3', 'result') ;
        end
    else
        mkdir(cache_folder_path) ;
        % We know memo_file_name doesn't exist, b/c we just created its
        % parent folder
        result = feval(compute_function) ;
        save(memo_file_path, '-mat', '-v7.3', 'result') ;        
    end
end
