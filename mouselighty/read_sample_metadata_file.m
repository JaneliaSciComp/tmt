function result = read_sample_metadata_file(raw_tile_folder_path)    
    % Read the channel semantics file and extract the relevant information
    sample_metadata_file_path = fullfile(raw_tile_folder_path, 'sample-metadata.txt') ;
    sample_metadata_lines = read_file_into_cellstring(sample_metadata_file_path) ;
    name_from_field_index = {'neuron_channel_index', 'background_channel_index', 'is_x_flipped', 'is_y_flipped'} ;
    field_count = length(name_from_field_index) ;
    was_specified_from_field_index = false(1, field_count) ;
    result = struct() ;    
    for line_index = 1: length(sample_metadata_lines) ,        
        line = strtrim(sample_metadata_lines{line_index}) ;
        if isempty(line) ,
            % skip empty lines
            continue
        end
        tokens = strtrim(strsplit(line, ':')) ;
        if length(tokens) ~= 2 ,
            error('Unable to parse line in channel semantics file: "%s"', line) ;
        end
        field_name = tokens{1} ;
        value_as_string = tokens{2} ;
        if strcmp(field_name, 'neuron_channel_index') ,
            value = str2double(value_as_string) ;
            if value ~= 0 && value ~= 1 ,
                error('Bad %s field in sample metadata file: "%s"', field_name, value_as_string) ;
            end
            result.neuron_channel_index = value ;
            field_index = find(strcmp(field_name, name_from_field_index)) ;
            if isscalar(field_index) ,
                was_specified_from_field_index(field_index) = true ;
            end
        elseif strcmp(field_name, 'background_channel_index') ,
            value = str2double(value_as_string) ;
            if value ~= 0 && value ~= 1 ,
                error('Bad %s field in sample metadata file: "%s"', field_name, value_as_string) ;
            end
            result.background_channel_index = value ;
            field_index = find(strcmp(field_name, name_from_field_index)) ;
            if isscalar(field_index) ,
                was_specified_from_field_index(field_index) = true ;
            end
        elseif strcmp(field_name, 'is_x_flipped') ,
            try
                value = str2logical(value_as_string) ;
            catch me
                if strcmp(me.identifier, 'str2logical:bad_input') ,
                    error('Bad value for %s field in sample metadata file: "%s"', field_name, value_as_string) ;
                else
                    rethrow(me) ;
                end
            end                    
            result.is_x_flipped = value ;
            field_index = find(strcmp(field_name, name_from_field_index)) ;
            if isscalar(field_index) ,
                was_specified_from_field_index(field_index) = true ;
            end
        elseif strcmp(field_name, 'is_y_flipped') ,
            try
                value = str2logical(value_as_string) ;
            catch me
                if strcmp(me.identifier, 'str2logical:bad_input') ,
                    error('Bad value for %s field in sample metadata file: "%s"', field_name, value_as_string) ;
                else
                    rethrow(me) ;
                end
            end                    
            result.is_y_flipped = value ;
            field_index = find(strcmp(field_name, name_from_field_index)) ;
            if isscalar(field_index) ,
                was_specified_from_field_index(field_index) = true ;
            end
        else
            fprintf('Warning: Unknown field "%s" in sample metadata file\n', field_name) ;
        end            
    end
    if ~all(was_specified_from_field_index) ,
        name_from_missing_field_index = name_from_field_index(~was_specified_from_field_index) ;
        missing_field_count = length(name_from_missing_field_index) ;
        if missing_field_count == 1 ,
            missing_field_name = name_from_missing_field_index{1} ;
            error('read_sample_metadata_file:missing_fields', 'Missing field %s in file %s', missing_field_name, channel_semantics_file_name) ;
        else
            % Assemble error message
            error_message = sprintf('There were missing fields in file %s:\n', channel_semantics_file_name) ;
            for missing_field_index = 1 : missing_field_count ,
                missing_field_name = name_from_missing_field_index{missing_field_index} ;
                line = sprintf('    %s\n', missing_field_name) ;
                error_message = horzcat(error_message, line) ;  s%#ok<AGROW>
            end
            % Throw the error
            error('read_sample_metadata_file:missing_fields', error_message) ;
        end
    end    
end
