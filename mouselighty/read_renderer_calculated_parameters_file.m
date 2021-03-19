function params = read_renderer_calculated_parameters_file(parameter_file_name)
    % reads calculated_parameters.txt file and parse it into a transform
    % const jobname = "ocJHfFH"
    % const nlevels = 6
    % const nchannels = 2
    % const shape_leaf_px = [406,256,152]
    % const voxelsize_used_um = [0.329714,0.342888,1.00128]
    % const origin_nm = [61677816,45421726,16585827]
    % const tile_type = convert(Cint,1)
    % const render_version = "2017-03-06 14:11:38 -0500 ec13bbfa7f9285447d3b9702b96a1f1afb847244"
    % const mltk_bary_version = "2016-11-11 12:16:03 -0500 84e153640047e3830abf835e1da4b738efa679d3"
    % const tilebase_version = "2016-08-22 15:49:39 -0400 cc171869a904e9e876426f2bb2732a38e607a102"
    % const nd_version = "2016-11-17 08:30:01 -0500 ef4923831c7bddadd0bba6b706f562a7cde00183"
    % const ndio_series_version = "2016-08-23 11:11:13 -0400 fdfe30a71f3d97fad6ac9982be50d8aea90b5234"
    % const ndio_tiff_version = "2016-08-23 11:11:54 -0400 df46d485cdf55ba66b8ed16fcf9fd9f3d5892464"
    % const ndio_hdf5_version = "2016-08-30 14:25:54 -0400 0c7ac77c5ca535913bfae5300159e6bdf60e36ca"
    % const mylib_version = "2013-08-06 19:15:35 -0400 0ca27aae55a5bab44263ad2e310e8f4507593ddc"
    params = struct() ;  % initialize dictionary
    f = fopen(parameter_file_name, 'rt') ;
    if f<0 ,
        error('Unable to open parameter file %s', parameter_file_name) ;
    end
    cleaner = onCleanup(@()(fclose(f))) ;
    for line_index = 1:256 ,  % only process this many lines max
        text = fgetl(f) ;
        if isempty(text) || (isnumeric(text) && text < 0) ,
            break
        end
        parts = strsplit(text, '=') ;
        keyval = strtrim(parts{1}) ;
        if isequal(keyval, 'const nlevels') ,
            params.level_step_count = eval(strtrim(parts{2})) ;
        elseif isequal(keyval, 'const shape_leaf_px') ,
            params.leaf_shape = eval(strtrim(parts{2})) ;
        elseif isequal(keyval, 'const voxelsize_used_um') ,
            params.spacing = eval(strtrim(parts{2})) ;
        elseif isequal(keyval, 'const origin_nm') ,
            params.origin = 0.001 * eval(strtrim(parts{2})) ;  % convert to um
        elseif isequal(keyval, 'const nchannels') ,
            params.channel_count = eval(strtrim(parts{2})) ;
        else
            % ignore line
        end
    end
end
