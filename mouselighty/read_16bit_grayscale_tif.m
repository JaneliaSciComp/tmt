function stack = read_16bit_grayscale_tif(file_name)
    info = imfinfo(file_name, 'tif') ;
    n_pages = length(info) ;
    if n_pages>0 ,
        first_frame_info = info(1) ;
        n_cols = first_frame_info.Width;
        n_rows = first_frame_info.Height;
    else
        n_cols = 0 ;
        n_rows = 0 ;
    end
    stack  = zeros([n_rows n_cols n_pages], 'uint16');
    original_warning_state = warning('query', 'imageio:tiffmexutils:libtiffWarning') ;
    warning('off', 'imageio:tiffmexutils:libtiffWarning') ;
    tif_link = Tiff(file_name, 'r') ;
    for i = 1:n_pages ,
        tif_link.setDirectory(i) ;
        stack(:,:,i) = tif_link.read() ;
    end
    warning(original_warning_state) ;
    tif_link.close() ;  % do I even need this?  
end
