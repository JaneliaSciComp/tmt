function result = get_file_size(path)
    d = dir(path) ;
    if isempty(d) ,
        error('File %s does not exist, seemingly', path) ;
    elseif length(d) == 1 ,
        if d.isdir ,
            error('%s seems to be a folder, not a regular file', path) ;
        else
            result = d.bytes ;
        end        
    else
        error('The path %s does not seem to refer to a regular file', path) ;        
    end
end
