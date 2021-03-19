function result = read_xlineshift_file(file_name) 
    fid = fopen(file_name, 'rt') ;
    if fid<0 ,
        error('Unable to open file %s', file_name) ;
    end
    cleaner = onCleanup(@()(fclose(fid))) ;
    result = fscanf(fid, '%d', 1) ;    
    %file_as_string = fread(fid, inf, 'uint8=>uint8') ;
    %result = str2double(file_as_string) ;    
end
