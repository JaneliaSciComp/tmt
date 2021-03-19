function generate_fragments_higher_level(sample_date, ...
                                         minimum_centerpoint_count_per_fragment, ...
                                         bounding_box_low_corner_xyz, ...
                                         bounding_box_high_corner_xyz)
                                     
    fprintf('\n\nGenerating fragments...\n') ;                                     
    outer_tic_id = tic() ;
                                     
    % Set paths, etc                                             
    input_folder_path = ...
        sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s/build-brain-output/full-as-named-tree-mats', ...
                sample_date) ;
    output_folder_path = ...
        sprintf('/groups/mousebrainmicro/mousebrainmicro/cluster/Reconstructions/%s/build-brain-output/frags-with-5-or-more-nodes', ...
                sample_date) ;       
    maximum_core_count_desired = inf ;
                          
    % Actually generate the fragments
    generate_fragments(input_folder_path, ...
                       output_folder_path, ...
                       maximum_core_count_desired, ...
                       minimum_centerpoint_count_per_fragment, ...
                       bounding_box_low_corner_xyz, ...
                       bounding_box_high_corner_xyz)    

    % Count the number of fragments
    swc_output_folder_path = fullfile(output_folder_path, 'as-swcs') ;
    command_line = sprintf('ls -U "%s" | wc -l', swc_output_folder_path) ;
    [status, stdout] = system(command_line) ;
    if status ~= 0 ,
        error('There was a problem running the command %s.  The return code was %d', command_line, status) ;
    end
    fragment_count = str2double(stdout) ;
    if ~isfinite(fragment_count) ,
        error('There was a problem running the command %s.  Unable to parse output.  Output was: %s', command_line, stdout) ;
    end    
    fprintf('Fragment count: %d\n', fragment_count) ;
    
    elapsed_time = toc(outer_tic_id) ;
    fprintf('Done generating fragments.  Elapsed time to generate fragments: %g sec.\n', elapsed_time) ;
end
