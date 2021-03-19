function result = does_md5_match(file_name, md5_value) 
    file_md5 = md5sum(file_name) ;
    result = isequal(file_md5, md5_value) ;
end
