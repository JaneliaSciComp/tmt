function write_string_to_file(file_name, str)
    fid = fopen(file_name, 'wt') ;
    if fid<0 ,
        error('Unable to open file %s for writing', file_name) ;
    end
    cleaner = onCleanup(@()(fclose(fid))) ;
    fprintf(fid, '%s', str) ;
    % fclose handled by cleaner
end
