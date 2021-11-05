function [result, tile_root_path] = tile_relative_path_from_tile_file_path(tile_file_path)
    % E.g.
    % '/groups/mousebrainmicro/mousebrainmicro/data/2021-09-16/Tiling/2021-09-17/00/00000'
    % -> '2021-09-17/00/00000'
    % Return value tile_root_path in this case would be
    % '/groups/mousebrainmicro/mousebrainmicro/data/2021-09-16/Tiling'
    
    tile_folder_path = fileparts2(tile_file_path) ;
    [rest1, day_tile_index_as_string] = fileparts2(tile_folder_path) ;
    [rest2, day_tile_index_prefix_as_string] = fileparts2(rest1) ;
    [tile_root_path, tile_date] = fileparts2(rest2) ;
    result = fullfile(tile_date, day_tile_index_prefix_as_string, day_tile_index_as_string) ;
end
