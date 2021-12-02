function is_runnable_from_rule_index = compute_is_runnable_from_rule_index(rule_from_rule_index)
    is_runnable_from_rule_index = arrayfun(@is_rule_runnable, rule_from_rule_index) ;
end
