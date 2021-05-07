function result = collect_z_face_matches(match_folder_path, relative_path_from_tile_index, background_channel_index, has_z_plus_1_tile_from_tile_index)
    % I'm not sure if those landmark locations are ijk1 or ijk0 coords...
    
    tile_count = length(relative_path_from_tile_index) ;
    self_ijk_from_match_index_from_tile_index = cell(tile_count, 1) ;
    neighbor_ijk_from_match_index_from_tile_index = cell(tile_count, 1) ;
    for tile_index = 1 : tile_count ,
        has_z_plus_1_tile = has_z_plus_1_tile_from_tile_index(tile_index) ;
        if has_z_plus_1_tile ,
            tile_relative_path = relative_path_from_tile_index{tile_index} ;
            match_file_name = 'match-Z.mat' ;
            match_file_path = fullfile(match_folder_path, tile_relative_path, match_file_name) ;
            if exist(match_file_path, 'file') ,
                data = load(match_file_path) ;
                self_ijk_from_match_index = data.paireddescriptor.X ;
                neighbor_ijk_from_match_index = data.paireddescriptor.Y ;
            else
                fprintf('Missing (?) match file for tile %s\n', tile_relative_path) ;
                self_ijk_from_match_index = zeros(0,3) ;
                neighbor_ijk_from_match_index = zeros(0,3) ;
            end
            self_ijk_from_match_index_from_tile_index{tile_index} = self_ijk_from_match_index ;
            neighbor_ijk_from_match_index_from_tile_index{tile_index} = neighbor_ijk_from_match_index ;
        end
    end
    result = struct() ;
    result.self_ijk_from_match_index_from_tile_index = self_ijk_from_match_index_from_tile_index ;
    result.neighbor_ijk_from_match_index_from_tile_index = neighbor_ijk_from_match_index_from_tile_index ;
end
