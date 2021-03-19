function result = md5sum(file_name)
    % Gets the md4sum of the file, returns it as a row vector of uint8's
    [status, stdout] = system(sprintf('md5sum %s', file_name)) ;
    if status==0 ,
        tokens = strsplit(stdout) ;
        if isempty(tokens) ,
            error('Problem calling md5sum on file %s: Unable to parse output', file_name) ;
        end
        checksum_as_string = tokens{1} ;        
        char_count = length(checksum_as_string) ;
        if mod(char_count,2) ~= 0 ,
            error('md5 checksum has an off number of characters') ;
        end
        byte_count = round(char_count/2) ;
        result = hex2dec(reshape(checksum_as_string', [2 byte_count])')' ;
    else
        error('Problem calling md5sum on file %s', file_name) ;
    end
end
