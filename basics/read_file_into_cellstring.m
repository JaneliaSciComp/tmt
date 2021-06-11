function result = read_file_into_cellstring(file_name)
    % Read a while file into a cellstring, one line per element.
    % Newlines are discarded.
    fid = fopen(file_name, 'rt') ;
    if fid<0 ,
        error('Unable to open file %s for reading', file_name) ;
    end
    cleaner = onCleanup(@()(fclose(fid))) ;
    result = cell(0,1) ;
    line = fgetl(fid) ;
    while ischar(line) ,
        result = vertcat(result, ...
                         {line}) ;  %#ok<AGROW>
        line = fgetl(fid) ;
    end
end
