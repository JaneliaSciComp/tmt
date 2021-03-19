function result = does_match_regexp(str, re)
    % Just returns a simple boolean saying whether any part of str matches re.
    % str can also be a cell array of strings, in which case result is an array of logicals.
    if ischar(str) && ( isempty(str) || isrow(str) ),
        result = ~isempty(regexp(str, re, 'once')) ;
    elseif isstring(str) ,
        result = ~isempty(regexp(str, re, 'once')) ;        
    elseif iscellstr(str) ,
        regexp_result = regexp(str, re, 'once') ;
        result = ~cellfun(@isempty, regexp_result) ;
    else
        error('str should be either a char row vector, a string, or a cell string') ;
    end
end
