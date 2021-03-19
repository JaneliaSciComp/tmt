function find_and_verify(root_folder_path, does_need_verification_predicate, verify_function, varargin)
    tic_id = tic() ;
    verified_ok_count = 0 ;
    problem_paths = cell(1,0) ;
    [verified_ok_count, problem_paths] = ...
        find_and_verify_helper(root_folder_path, ...
                               does_need_verification_predicate, ...
                               verify_function, ...                               
                               verified_ok_count, ...
                               problem_paths, ...
                               varargin{:}) ;
    if isempty(problem_paths) ,
        fprintf(['All files with names matching the predicate function %s() in folder \n' ...
                 '    %s\n' ...
                 '    were successfully verified with function %s().\n'], ...
                func2str(does_need_verification_predicate), ...
                root_folder_path, ...
                func2str(verify_function)) ;
        fprintf('Hooray!\n') ;
        fprintf('%d files checked\n', verified_ok_count) ;
    else
        fprintf('Verification with function %s() failed for some paths:\n', func2str(verify_function)) ;
        problem_paths_count = length(problem_paths) ;
        paths_to_show_count = min(problem_paths_count, 20) ;
        for i = 1 : paths_to_show_count ,
            fprintf('  %s\n', problem_paths{i}) ;
        end
        if paths_to_show_count < problem_paths_count ,
            fprintf('  (%d more paths, %d total problematic paths)\n', problem_paths_count-paths_to_show_count, problem_paths_count) ;
        end
        fprintf('Boo!\n') ;
        error('Verification with function %s() failed for some paths', func2str(verify_function)) ;
    end    
    elapsed_time = toc(tic_id) ;
    fprintf('Elapsed time for verifcation was %g seconds.\n', elapsed_time) ;
end



function [verified_ok_count, problem_paths] = ...
        find_and_verify_helper(current_folder_path, ...
                               does_need_verification_predicate, ...
                               verify_function, ...
                               verified_ok_count, ...
                               problem_paths, ...
                               varargin)
                                                 
    [file_names, is_file_a_folder] = simple_dir(current_folder_path) ;
    raw_tiles_input_entity_count = length(file_names) ;
    for i = 1 : raw_tiles_input_entity_count ,
        file_name = file_names{i} ;        
        is_this_file_a_folder = is_file_a_folder(i) ;
        file_path = fullfile(current_folder_path, file_name) ;
        if is_this_file_a_folder ,
            % if a folder, recurse
            [verified_ok_count, problem_paths] = ...
                find_and_verify_helper(file_path, ...
                                       does_need_verification_predicate, ...
                                       verify_function, ...
                                       verified_ok_count, ...
                                       problem_paths, ...
                                       varargin{:}) ;
        else
            %tif_input_entity_path = fullfile(tif_input_folder_name, tif_input_entity_name) ;    
            %[~,~,ext] = fileparts(raw_tiles_input_entity_name) ;
            if feval(does_need_verification_predicate, file_path, varargin{:})  ,
                % If source is a tif with the right kind of name, check for the corresponding checkpoint files                
                is_verified = feval(verify_function, file_path, varargin{:}) ;
                if is_verified ,
                    verified_ok_count = verified_ok_count + 1 ;
                else
                    problem_paths = horzcat(problem_paths, {file_path}) ;  %#ok<AGROW>
                end
            end
        end
    end    
end
