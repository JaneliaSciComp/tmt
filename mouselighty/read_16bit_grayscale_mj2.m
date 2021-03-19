function stack = read_16bit_grayscale_mj2(file_name)
    input_file = VideoReader(file_name) ;
    n_rows = input_file.Height ;
    n_cols = input_file.Width ;
    n_pages_approx = ceil(input_file.FrameRate * input_file.Duration) ;  % hopefully big enough
    stack = zeros([n_rows n_cols n_pages_approx], 'uint16') ;
    frame_index = 0 ;
    while input_file.hasFrame() ,
        frame_index = frame_index + 1 ; 
        frame = input_file.readFrame() ;
        stack(:,:,frame_index) = frame ;
    end    
    n_pages = frame_index ;
    stack = stack(:,:,1:n_pages) ;  
end
