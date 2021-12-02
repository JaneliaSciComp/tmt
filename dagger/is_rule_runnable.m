function is_runnable = is_rule_runnable(rule)
    name_from_input_file_index = rule.name_from_input_file_index ;
    
    does_exist_from_input_file_index = ...
        cellfun(@(name)(exist(name, 'file')), name_from_input_file_index) ;
    is_runnable = all(does_exist_from_input_file_index) ;
end
