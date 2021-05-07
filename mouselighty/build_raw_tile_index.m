function result = build_raw_tile_index(raw_tiles_path)
    % Build an index of the raw tiles, given the path to the raw tiles    
    % On return, result is a scalar struct with three fields:
    %   .ijk1_from_tile_index: a tile_count x 3 array giving the integral, one-based xyz position
    %                          of each tile.  Columns are in xyz order, tile index is
    %                          essentially arbitrary.
    %   .xyz_from_tile_index: a tile_count x 3 array giving the xyz position
    %                         of each tile in um.  Columns are in xyz order, tile indices are 
    %                         the same as in the ijk1_from_tile_index field.
    %   .relative_path_from_tile_index: a tile_count x 1 cell array.  Each element
    %                                   contains the relative path of that tile.
    %                                   Tile indices are the same as in the
    %                                   ijk1_from_tile_index field.
    %   .tile_index_from_ijk1: a 3D array that maps from integer, one-based xyz
    %                          position to the tile index.
    
    initial_index_as_struct = struct() ;
    initial_index_as_struct.ijk1_from_tile_index = zeros(0,3) ;
    initial_index_as_struct.xyz_from_tile_index = zeros(0,3) ;
    initial_index_as_struct.relative_path_from_tile_index = cell(0,1) ;
    
    index_as_struct = dirwalk(raw_tiles_path, @build_tile_index_dirwalk_callback, initial_index_as_struct) ;        
    ijk1_from_tile_index = index_as_struct.ijk1_from_tile_index ;
    xyz_from_tile_index = index_as_struct.xyz_from_tile_index ;
    relative_path_from_tile_index = index_as_struct.relative_path_from_tile_index ;
    tile_count = length(relative_path_from_tile_index) ;
    result_shape = max(ijk1_from_tile_index) ;
    tile_index_from_ijk1 = nan(result_shape) ;
    for tile_index = 1 : tile_count ,
        ijk1 = ijk1_from_tile_index(tile_index,:) ;
        tile_index_from_ijk1(ijk1(1), ijk1(2), ijk1(3)) = tile_index ;
    end
    
    result = struct() ;
    result.ijk1_from_tile_index = ijk1_from_tile_index ;
    result.xyz_from_tile_index = xyz_from_tile_index ;
    result.relative_path_from_tile_index = relative_path_from_tile_index ;
    result.tile_index_from_ijk1 = tile_index_from_ijk1 ;
end
