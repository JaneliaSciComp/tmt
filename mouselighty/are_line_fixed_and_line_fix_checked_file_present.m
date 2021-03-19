function result = are_line_fixed_and_line_fix_checked_file_present(raw_tile_file_path, ...
                                                                   raw_tiles_root_folder_path, ...
                                                                   line_fixed_root_folder_path)
    tile_relative_path = relpath(raw_tile_file_path, raw_tiles_root_folder_path) ;
    line_fixed_tile_path = fullfile(line_fixed_root_folder_path, tile_relative_path) ;
    check_file_path = horzcat(raw_tile_file_path, '.line-fix-checked') ;
    result = logical(exist(line_fixed_tile_path, 'file')) && logical(exist(check_file_path, 'file')) ;
end
