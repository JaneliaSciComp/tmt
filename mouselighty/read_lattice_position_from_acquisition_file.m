function [ijk1, xyz] = read_lattice_position_from_acquisition_file(acquisition_file_name)
    % Reads the integral lattice position of the tile from the .acquisition file.
    % ijk1 is in xyz order, and contains one-based indices.
    
    % Read the file in, convert to tokens
    file_text = fileread(acquisition_file_name) ;
    file_text_without_colons = strrep(file_text, ':', '') ;  % remove the colons, since we don't need them
    tokens = strsplit(file_text_without_colons) ;
    
    % Get the x_mm, y_mm, z_mm values
    x_mm = find_label_and_get_value_in_acquisition_file(tokens, 'x_mm') ;
    y_mm = find_label_and_get_value_in_acquisition_file(tokens, 'y_mm') ;
    z_mm = find_label_and_get_value_in_acquisition_file(tokens, 'z_mm') ;    
    xyz = 1e3*[x_mm y_mm z_mm] ;

    % Get the integral lattice position
    is_current_lattice_position = strcmp('current_lattice_position', tokens) ;
    clp_token_index = find(is_current_lattice_position, 1) ;
    if isempty(clp_token_index) ,
        error('Unable to find "current_lattice_position" in file %s', acquisition_file_name) ;
    end
    i1_value = check_label_and_get_value_in_acquisiton_file(tokens, clp_token_index + 2, 'x') ;
    j1_value = check_label_and_get_value_in_acquisiton_file(tokens, clp_token_index + 4, 'y') ;
    k1_value = check_label_and_get_value_in_acquisiton_file(tokens, clp_token_index + 6, 'z') ;
    ijk1 = [i1_value j1_value k1_value] ;    
end



function result = check_label_and_get_value_in_acquisiton_file(tokens, putative_label_index, desired_label_string)
    % Get a single value out of an array of tokens, with error checking.
    % tokens{putative_label_index} should equal desired_label_string, and the next
    % token should hold a floating-point value.  If any of these constraints are
    % violated, an error is thrown.
    if length(tokens)<putative_label_index+1 ,
        error('Ran out of tokens when trying to read "%s" value', desired_label_string) ;
    end
    putative_label = tokens{putative_label_index} ;
    if ~isequal(putative_label, desired_label_string) ,
        error('Expected "%s", but token was "%s"', desired_label_string, putative_label) ;
    end
    result_as_string = tokens{putative_label_index+1} ;
    result = str2double(result_as_string) ;
    if ~isfinite(result) || round(result)~=result || result<0 ,
        error('Value %s is not valid', result_as_string) ;
    end    
end
