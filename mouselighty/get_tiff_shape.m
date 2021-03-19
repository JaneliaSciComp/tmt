function [result, bits_per_pixel] = get_tiff_shape(file_name)
    % returns shape in yxz order
    info = imfinfo(file_name, 'tif') ;
    bits_per_pixel = info.BitDepth ;
    n_pages = length(info) ;
    if n_pages>0 ,
        first_frame_info = info(1) ;
        n_cols = first_frame_info.Width;
        n_rows = first_frame_info.Height;
    else
        n_cols = 0 ;
        n_rows = 0 ;
    end
    result = [n_rows n_cols n_pages] ;
end
   