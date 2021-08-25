function result = build_raw_tile_index(raw_tiles_path, manual_tile_shape_ijk)
    % Build an index of the raw tiles, given the path to the raw tiles    
    % On return, result is a scalar struct with three fields:
    %   .tileijk1_from_tile_index: a tile_count x 3 array giving the integral, one-based xyz position
    %                              of each tile.  Columns are in xyz order, tile index is
    %                              essentially arbitrary.
    %   .xyz_from_tile_index: a tile_count x 3 array giving the xyz position
    %                         of each tile in um.  Columns are in xyz order, tile indices are 
    %                         the same as in the ijk1_from_tile_index field.
    %   .relative_path_from_tile_index: a tile_count x 1 cell array.  Each element
    %                                   contains the relative path of that tile.
    %                                   Tile indices are the same as in the
    %                                   ijk1_from_tile_index field.
    %   .tile_index_from_tile_ijk1: a 3D array that maps from integer, one-based xyz
    %                               position to the tile index.
    
    if ~exist('manual_tile_shape_ijk', 'var') || isempty(manual_tile_shape_ijk) ,
        manual_tile_shape_ijk = [] ;
    end
    
    initial_index_as_struct = struct() ;
    initial_index_as_struct.ijk1_from_tile_index = zeros(0,3) ;
    initial_index_as_struct.xyz_from_tile_index = zeros(0,3) ;
    initial_index_as_struct.relative_path_from_tile_index = cell(0,1) ;
    
    index_as_struct = dirwalk(raw_tiles_path, @build_tile_index_dirwalk_callback, initial_index_as_struct) ;        
    raw_tile_ijk1_from_tile_index = index_as_struct.ijk1_from_tile_index ;
    xyz_from_tile_index = index_as_struct.xyz_from_tile_index ;
    relative_path_from_tile_index = index_as_struct.relative_path_from_tile_index ;
    tile_count = length(relative_path_from_tile_index) ;
    
    % Shift the lattice coordinates so the lowest one in the bounding cuboid is [1 1 1]
    min_raw_tile_ijk1 = min(raw_tile_ijk1_from_tile_index, [], 1) ;
    tile_ijk1_from_tile_index = raw_tile_ijk1_from_tile_index - min_raw_tile_ijk1 + 1 ;   
    
    % Make the 3d array of tile indices
    tile_lattice_shape = max(tile_ijk1_from_tile_index) ;
    tile_index_from_tile_ijk1 = nan(tile_lattice_shape) ;
    for tile_index = 1 : tile_count ,
        ijk1 = tile_ijk1_from_tile_index(tile_index,:) ;
        tile_index_from_tile_ijk1(ijk1(1), ijk1(2), ijk1(3)) = tile_index ;
    end
    
    % Make an array showing which tiles exist
    does_exist_from_tile_ijk1 = isfinite(tile_index_from_tile_ijk1) ;
    
    % Read in a single tile to get the tile shape
    working_channel_index = 0 ;
    middle_tile_index = round(tile_count/2) ;
    relative_path = relative_path_from_tile_index{middle_tile_index} ;
    if ~isempty(manual_tile_shape_ijk) ,
        tile_shape_ijk = manual_tile_shape_ijk ;
    else        
        imagery_file_relative_path = imagery_file_relative_path_from_relative_path(relative_path, working_channel_index) ;
        imagery_file_path = fullfile(raw_tiles_path, imagery_file_relative_path) ;
        raw_tile_stack_yxz_flipped = read_16bit_grayscale_tif(imagery_file_path) ;
        tile_shape_jik = size(raw_tile_stack_yxz_flipped) ;
        tile_shape_ijk = tile_shape_jik([2 1 3]) ;
    end
    
    % Read in a single .acquisiton file to get the voxel spacing
    [~,file_base_name] = fileparts2(relative_path) ;
    acquisition_file_name = [file_base_name '-ngc.acquisition'] ;
    acquisition_file_path = fullfile(raw_tiles_path, relative_path, acquisition_file_name) ;
    tile_fov_shape_um_xyz = read_fov_shape_from_acquisition_file(acquisition_file_path) ;  % um
    spacing_um_xyz = tile_fov_shape_um_xyz ./ (tile_shape_ijk-1) ;  % um, this is the convention the FOV field uses
    
    % Package things for return
    result = struct() ;
    result.tile_shape_ijk = tile_shape_ijk ;
    result.spacing_um_xyz = spacing_um_xyz ;  % um
    result.raw_ijk1_from_tile_index = raw_tile_ijk1_from_tile_index ;
    result.ijk1_from_tile_index = tile_ijk1_from_tile_index ;
    result.xyz_from_tile_index = xyz_from_tile_index ;
    result.relative_path_from_tile_index = relative_path_from_tile_index ;
    result.tile_index_from_tile_ijk1 = tile_index_from_tile_ijk1 ;
    result.does_exist_from_tile_ijk1 = does_exist_from_tile_ijk1 ;
end
