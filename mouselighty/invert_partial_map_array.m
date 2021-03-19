function a_from_b = invert_partial_map_array(b_from_a, n_b)
    % b_from_a a vector of length n_a, each element an integer on [1,n_b], or nan.
    % b_from_a represents a partial function from [1,n_a] to [1,n_b].
    %
    % On return, a_from_b is such that a_from_b(b_from_a(i)) == i for all
    % integers i in the domain of b_from_a.
    
    if isrow(b_from_a) ,        
        b_from_a = b_from_a' ;
        do_need_to_transpose_result = true ;
    else
        do_need_to_transpose_result = false ;        
    end
    a_from_domain_index = find(isfinite(b_from_a)) ;
    b_from_domain_index = b_from_a(a_from_domain_index) ;
    
    a_from_b = nan(n_b, 1) ;
    a_from_b(b_from_domain_index) = a_from_domain_index ;
    
    if do_need_to_transpose_result ,
        a_from_b = a_from_b' ;
    end
end
