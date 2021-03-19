function write_file_from_cellstring(file_name, cellstr)
    fid = fopen(file_name, 'wt') ;
    if fid<0 ,
        error('Unable to open file %s for writing', file_name) ;
    end
    cleaner = onCleanup(@()(fclose(fid))) ;
    line_count = length(cellstr) ;
    for i = 1 : line_count ,
        fprintf(fid, '%s\n', cellstr{i}) ;
    end
end
