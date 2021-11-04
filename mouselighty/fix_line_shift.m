function fix_line_shift(input_root_folder, tile_relative_path, output_root_folder, do_force_computation, do_run_in_debug_mode)
    % Deal with args
    if ~exist('do_force_computation', 'var') || isempty(do_force_computation) ,
        do_force_computation = false ;
    end
    if ~exist('do_run_in_debug_mode', 'var') || isempty(do_run_in_debug_mode) ,
        do_run_in_debug_mode = false ;
    end

    % Set some internal parmeters
    min_shift = -9 ;
    max_shift = +9 ;
    
    % Figure out which channel we'll use to compute the line shift
    %neurons_channel_index = read_channel_semantics_file(input_root_folder) ;
    sample_metadata = read_sample_metadata_file(input_root_folder) ;
    neuron_channel_index = sample_metadata.neuron_channel_index ;
    is_x_flipped = sample_metadata.is_x_flipped ;
    is_y_flipped = sample_metadata.is_y_flipped ;
    
    % Construct absolute paths to input, output folder for this tile
    input_folder_path = fullfile(input_root_folder, tile_relative_path) ;
    output_folder_path = fullfile(output_root_folder, tile_relative_path) ;
    [~, tile_base_name] = fileparts2(tile_relative_path) ;
    
    % Get the file paths for the output files
    xlineshift_file_path = fullfile(output_folder_path, 'Xlineshift.txt') ;
    thumb_file_path = fullfile(output_folder_path, 'Thumbs.png') ;
    tif_file_names = simple_dir(fullfile(input_folder_path,'*.tif')) ;
    output_file_path_from_tif_index = cellfun(@(tif_file_name)(fullfile(output_folder_path, tif_file_name)), ...
                                              tif_file_names, ...
                                              'UniformOutput', false) ;

    % Read or generate the Xlineshift.txt file                                          
    if exist(xlineshift_file_path, 'file') && ~do_force_computation,
        shift = read_xlineshift_file(xlineshift_file_path) ;
    else
        % read image
        neurons_channel_tif_file_name = [tile_base_name '-ngc.' num2str(neuron_channel_index) '.tif'] ;
        neurons_channel_tif_file_path = fullfile(input_folder_path, neurons_channel_tif_file_name) ;
        raw_stack = read_16bit_grayscale_tif(neurons_channel_tif_file_path) ;

        % binarize it to eliminate spatial non-uniformity bias
        serial_stack = double(raw_stack(:)) ;
        middle_value = mean(quantile(serial_stack,[0.0001 0.9999])) ;
        stack = (raw_stack>middle_value) ;
        [shift, shift_float] = find_shift(stack, min_shift, max_shift, false, do_run_in_debug_mode) ;
        % check if shift is closer to halfway. 0.4<|shift-round(shift)|<0.6
        if abs(abs(round(shift_float,2)-round(shift_float,0))-0.5) < 0.1 ,
            [shift, shift_float] = find_shift(stack, min_shift, max_shift, true, do_run_in_debug_mode) ;  %#ok<ASGLU>
        end

        % Make sure the output folder exists
        ensure_folder_exists(output_folder_path) ;

        % Write the Xlineshift.txt file
        write_xlineshift_file(xlineshift_file_path, shift) ; 
    end

    % Produce the thumbnail
    if ~exist(thumb_file_path, 'file') || do_force_computation ,
        cmap = rwb(max_shift-min_shift+1) ;
        col = cmap(shift-min_shift+1,:) ;
        thumbnail = uint8(255*repmat(reshape(col,[1 1 3]), [105 89])) ;
        imwrite(thumbnail, thumb_file_path) ;
    end

    % Write the line-shifted tif stacks
    input_file_path_from_tif_index = cellfun(@(tif_file_name)(fullfile(input_folder_path, tif_file_name)), ...
                                             tif_file_names, ...
                                             'UniformOutput', false) ;                                         
    tif_count = length(tif_file_names) ;
    for tif_index = 1 : tif_count ,
        input_tif_file_path = input_file_path_from_tif_index{tif_index} ;
        output_tif_file_path = output_file_path_from_tif_index{tif_index} ;
        if ~exist(output_tif_file_path, 'file')  || do_force_computation ,
            stack = read_16bit_grayscale_tif(input_tif_file_path) ;
            stack(2:2:end,:,:)  = circshift(stack(2:2:end,:,:), shift, 2) ;
                % shift every other y level, starting with the second, by shift voxels, in x
            % Apply any needed flips---want the output to be flipped in x and y, since
            % that's what the rest of the pipeline expects
            if is_x_flipped ,
                % do nothing, this is how we want it
            else
                stack = fliplr(stack) ;                
            end
            if is_y_flipped ,
                % do nothing, this is how we want it
            else
                stack = flipud(stack) ;                
            end
            write_16bit_grayscale_tif(output_tif_file_path, stack) ;
        end
    end
end

