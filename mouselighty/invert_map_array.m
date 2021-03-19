function a_from_b = invert_map_array(b_from_a)
    % b_from_a a vector, each element an integer >= 1.
    % On return, a_from_b is such that a_from_b(b_from_a(i)) == i for all integer i
    % on [1, n], where n is length(b_from_a).
    %
    % If b_from_a represents a function, a_from_b represents it's inverse.
    max_a = length(b_from_a) ;
    max_b = max(b_from_a) ;
    if iscolumn(b_from_a) ,
        a_from_b = zeros(max_b, 1) ;
    else
        a_from_b = zeros(1, max_b) ;
    end
    a_from_b(b_from_a) = 1:max_a ;
end
