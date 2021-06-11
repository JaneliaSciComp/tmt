function [neuron_channel_index, background_channel_index] = read_channel_semantics_file(raw_tile_folder_path)    
    % Read the channel semantics file and extract the relevant information
    channel_semantics_file_path = fullfile(raw_tile_folder_path, 'channel-semantics.txt') ;
    channel_semantics_lines = read_file_into_cellstring(channel_semantics_file_path) ;
    neuron_channel_index = nan ;
    background_channel_index = nan ;
    for line_index = 1: length(channel_semantics_lines) ,        
        line = strtrim(channel_semantics_lines{line_index}) ;
        if isempty(line) ,
            % skip empty lines
            continue
        end
        tokens = strsplit(line, ':') ;
        if length(tokens) ~= 2 ,
            error('Unable to parse line in channel semantics file: "%s"', line) ;
        end
        channel_index = str2double(tokens{1}) ;
        if channel_index ~= 0 && channel_index ~= 1 ,
            error('Bad channel index field in channel semantics file: "%s"', tokens{1}) ;
        end
        channel_type = strtrim(tokens{2}) ;
        if isequal(channel_type, 'neurons') 
            neuron_channel_index = channel_index ;
        elseif isequal(channel_type, 'background') ,
            background_channel_index = channel_index ;
        else            
            error('Bad channel type field in channel semantics file: "%s"', tokens{2}) ;
        end
    end
    if isnan(neuron_channel_index) || isnan(background_channel_index) ,
        error('Unable to determine neurons and/or background channel indices in file %s', channel_semantics_file_name) ;
    end    
end
