function are_targets_up_to_date_from_rule_index = compute_are_targets_up_to_date_from_rule_index(rule_from_rule_index)
    are_targets_up_to_date_from_rule_index = arrayfun(@compute_are_rule_targets_up_to_date, rule_from_rule_index) ;
end
    

