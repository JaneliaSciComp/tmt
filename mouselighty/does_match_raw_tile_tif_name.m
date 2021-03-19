function result = does_match_raw_tile_tif_name(file_path, varargin)
    [~,file_name] = fileparts2(file_path) ;
    result = does_match_regexp(file_name, '^\d\d\d\d\d-ngc\.\d\.tif$') ;
end
