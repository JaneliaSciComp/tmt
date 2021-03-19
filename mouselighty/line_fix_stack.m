function result = line_fix_stack(raw_stack, shift)
    % raw stack should be in yxz order, result will also be in this order
    raw_stack_even_scan_lines = raw_stack(2:2:end, :, :) ;
    result = raw_stack ;  % odd scan lines should remain unchanged
    result(2:2:end,:,:) = circshift(raw_stack_even_scan_lines, shift, 2) ;  % circular shift even scan lines in x dimension
end
