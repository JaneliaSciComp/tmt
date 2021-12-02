function are_up_to_date = compute_are_rule_targets_up_to_date(rule)
    name_from_input_file_index = rule.name_from_input_file_index ;
    name_from_output_file_index = rule.name_from_output_file_index ;
    
    does_exist_from_input_file_index = ...
        cellfun(@(name)(exist(name, 'file')), name_from_input_file_index) ;
    if all(does_exist_from_input_file_index) ,
        does_exist_from_output_file_index = ...
            cellfun(@(name)(exist(name, 'file')), name_from_output_file_index) ;
        if all(does_exist_from_output_file_index) ,
            % all input files exist
            % all output files exist
            % need to check dates
            mod_time_from_input_file_index = cellfun(@(name)(modtime(name)), name_from_input_file_index) ;
            mod_time_from_output_file_index = cellfun(@(name)(modtime(name)), name_from_output_file_index) ;
            earliest_output_mod_time = min(mod_time_from_output_file_index) ;
            most_recent_input_mod_time = max(mod_time_from_input_file_index) ;
            are_up_to_date = (earliest_output_mod_time > most_recent_input_mod_time) ;
        else
            % all input files exist
            % one or more output files does not exist
            are_up_to_date = false ;
        end
    else
        % one or more input files does not exist
        are_up_to_date = false ;
    end    
end
