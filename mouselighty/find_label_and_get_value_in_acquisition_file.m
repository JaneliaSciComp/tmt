function result = find_label_and_get_value_in_acquisition_file(tokens, desired_label_string)
    % Find a single labelled floating-point value in an array of tokens, with error checking.
    % In tokens, there should be one equal to desired_label_string.  This is found,
    % and the next token is converted to a double.  If something goes wrong, an
    % error is thrown.
    is_desired_token = strcmp(desired_label_string, tokens) ;
    desired_token_indices = find(is_desired_token) ;
    if isempty(desired_token_indices) ,
        error('Unable to find "%s" in file %s', desired_label_string, acquisition_file_name) ;
    elseif ~isscalar(desired_token_indices) ,        
        error('There are multiple occurances of label "%s" in file %s', desired_label_string, acquisition_file_name) ;
    end
    desired_token_index = desired_token_indices ;
    if length(tokens)<desired_token_index+1 ,
        error('Ran out of tokens when trying to read "%s" value', desired_label_string) ;
    end
    result_as_string = tokens{desired_token_index+1} ;
    % Check for a for-real nan
    if strcmpi(result_as_string, 'nan') ,
        result = nan ;
    else        
        result = str2double(result_as_string) ;
        if isnan(result) ,
            error('Value "%s" is not valid', result_as_string) ;
        end
    end
end
