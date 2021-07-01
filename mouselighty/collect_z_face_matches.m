function result = collect_z_face_matches(match_folder_path, ...
                                         relative_path_from_tile_index, ...
                                         background_channel_index, ...
                                         has_z_plus_1_tile_from_tile_index, ...
                                         tile_shape_ijk, ...
                                         does_use_new_style_file_names)
    tile_count = length(relative_path_from_tile_index) ;
    self_ijk0_from_match_index_from_tile_index = cell(tile_count, 1) ;
    neighbor_ijk0_from_match_index_from_tile_index = cell(tile_count, 1) ;
    if does_use_new_style_file_names ,
        match_file_name = sprintf('channel-%d-match-Z.mat', background_channel_index) ;
    else
        match_file_name = 'match-Z.mat' ;
    end
    for tile_index = 1 : tile_count ,
        has_z_plus_1_tile = has_z_plus_1_tile_from_tile_index(tile_index) ;
        if has_z_plus_1_tile ,
            tile_relative_path = relative_path_from_tile_index{tile_index} ;
            match_file_path = fullfile(match_folder_path, tile_relative_path, match_file_name) ;
            if exist(match_file_path, 'file') ,
                data = load(match_file_path) ;
                flipped_self_ijk0_from_match_index = data.paireddescriptor.X ;
                flipped_neighbor_ijk0_from_match_index = data.paireddescriptor.Y ;
                % the landmark-detection code is run on the the raw (flipped in x and y) tiles,
                % so need to un-flip the landmarks
                if isempty(flipped_self_ijk0_from_match_index) ,
                    self_ijk0_from_match_index = zeros(0,3) ;
                    neighbor_ijk0_from_match_index = zeros(0,3) ;
                else
                    self_ijk0_from_match_index = ...
                        [ (tile_shape_ijk(1)-1) - flipped_self_ijk0_from_match_index(:,1) ...
                          (tile_shape_ijk(2)-1) - flipped_self_ijk0_from_match_index(:,2) ...
                          flipped_self_ijk0_from_match_index(:,3) ] ;
                    neighbor_ijk0_from_match_index = ...
                        [ (tile_shape_ijk(1)-1) - flipped_neighbor_ijk0_from_match_index(:,1) ...
                          (tile_shape_ijk(2)-1) - flipped_neighbor_ijk0_from_match_index(:,2) ...
                          flipped_neighbor_ijk0_from_match_index(:,3) ] ;                
                end
            else
                fprintf('Missing (?) match file for tile %s\n', tile_relative_path) ;
                self_ijk0_from_match_index = zeros(0,3) ;
                neighbor_ijk0_from_match_index = zeros(0,3) ;
            end
            self_ijk0_from_match_index_from_tile_index{tile_index} = self_ijk0_from_match_index ;
            neighbor_ijk0_from_match_index_from_tile_index{tile_index} = neighbor_ijk0_from_match_index ;
        end
    end
    result = struct() ;
    result.self_ijk0_from_match_index_from_tile_index = self_ijk0_from_match_index_from_tile_index ;
    result.neighbor_ijk0_from_match_index_from_tile_index = neighbor_ijk0_from_match_index_from_tile_index ;
end
