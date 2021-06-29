function write_xlineshift_file(file_name, shift) 
    fid = fopen(file_name, 'wt') ;
    if fid<0 ,
        error('Unable to open file %s for writing', file_name) ;
    end
    cleaner = onCleanup(@()(fclose(fid))) ;
    fprintf(fid, '%d\n', shift) ;
end
