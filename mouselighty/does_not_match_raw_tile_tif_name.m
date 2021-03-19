function result = does_not_match_raw_tile_tif_name(file_name)
    result = ~(does_match_regexp(file_name, '^\d\d\d\d\d-ngc\.\d\.tif$')) ;
end
