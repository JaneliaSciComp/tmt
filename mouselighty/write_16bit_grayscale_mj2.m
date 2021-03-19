function write_16bit_grayscale_mj2(file_name, stack, compression_ratio) 
    %fprintf('Nominal file name in write_16bit_grayscale_mj2(): %s\n', file_name) ;
    [row_count, column_count, page_count] = size(stack) ;
    stack_for_video_writer = reshape(stack, [row_count, column_count 1 page_count]) ;
      % VideoWriter supports RGB, so have time in 4th dimension to disambiguate.
    vw = VideoWriter(file_name, 'Motion JPEG 2000') ;
    vw.CompressionRatio = compression_ratio ;
    vw.MJ2BitDepth = 16 ;
    vw.open() ;    
    vw.writeVideo(stack_for_video_writer) ;
    vw.close() ;
end
