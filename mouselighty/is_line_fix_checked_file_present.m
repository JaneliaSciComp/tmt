function result = is_line_fix_checked_file_present(file_path)
    check_file_name = horzcat(file_path, '.line-fix-checked') ;
    result = logical(exist(check_file_name, 'file')) ;
end
