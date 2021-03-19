function save_named_tree(file_name, named_tree)
    [~, ~, ext] = fileparts(file_name) ;
    if isequal(ext, '.swc') ,
        save_named_tree_as_swc(file_name, named_tree) ;
    elseif isequal(ext, '.mat') ,
        save_named_tree_as_mat(file_name, named_tree) ;
    else
        error('Don''t know how to save a named tree as a %s file', ext) ;
    end
end
