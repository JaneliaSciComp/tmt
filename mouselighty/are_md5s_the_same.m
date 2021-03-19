function result = are_md5s_the_same(file_name_1, file_name_2) 
    file_1_md5 = md5sum(file_name_1) ;
    file_2_md5 = md5sum(file_name_2) ;
    result = isequal(file_1_md5, file_2_md5) ;
end
