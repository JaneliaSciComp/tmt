function result = does_file_name_end_in_dot_tif(file_path, varargin)
    [~,file_name] = fileparts2(file_path) ;
    result = does_match_regexp(file_name, '\.tif$') ;
end
