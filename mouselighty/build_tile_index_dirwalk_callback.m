function updated_state = build_tile_index_dirwalk_callback(root_folder_absolute_path, current_folder_relative_path, folder_names, file_names, state)
    % Designed to be used in call to dirwalk() to build up an index of the ijk1
    % lattice positions of all the raw tiles.  E.g.:
    %
    %     initial_index_as_struct = struct() ;
    %     initial_index_as_struct.ijk1_from_tile_index = zeros(0,3) ;
    %     initial_index_as_struct.xyz_from_tile_index = zeros(0,3) ;
    %     initial_index_as_struct.relative_path_from_tile_index = cell(0,1) ;    
    %     index_as_struct = dirwalk(raw_tiles_path, @build_tile_index_dirwalk_callback, initial_index_as_struct) ;            

    if isempty(folder_names) ,
        % it's a leaf folder
        [~,file_base_name] = fileparts2(current_folder_relative_path) ;
        acquisition_file_name = [file_base_name '-ngc.acquisition'] ;
        acquisition_file_path = fullfile(root_folder_absolute_path, current_folder_relative_path, acquisition_file_name) ;
        if exist(acquisition_file_path, 'file') ,
            [ijk1, xyz] = read_lattice_position_from_acquisition_file(acquisition_file_path) ;
            updated_state = struct() ;
            updated_state.ijk1_from_tile_index = [state.ijk1_from_tile_index ; ijk1] ;
            updated_state.xyz_from_tile_index = [state.xyz_from_tile_index ; xyz] ;
            updated_state.relative_path_from_tile_index = state.relative_path_from_tile_index ;
            updated_state.relative_path_from_tile_index{end+1,1} = current_folder_relative_path ;        
        else
            updated_state = state ;
        end
    else
        updated_state = state ;
    end
end
