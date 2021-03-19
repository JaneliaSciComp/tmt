function [result, is_folder, file_size] = simple_dir(template)
    s = dir(template) ;
    raw_result = {s.name} ;
    raw_is_folder = [s.isdir] ;
    raw_file_size = [s.bytes] ;
    [~,indices_of_keepers] = setdiff(raw_result, {'.' '..'}) ;
    result = raw_result(indices_of_keepers) ;
    is_folder = raw_is_folder(indices_of_keepers) ;
    file_size = raw_file_size(indices_of_keepers) ;
end
