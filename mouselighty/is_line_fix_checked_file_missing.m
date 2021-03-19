function result = is_line_fix_checked_file_missing(file_name)
    check_file_name = horzcat(file_name, '.line-fix-checked') ;
    result = ~logical(exist(check_file_name, 'file')) ;
end
