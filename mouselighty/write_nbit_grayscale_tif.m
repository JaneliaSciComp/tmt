function write_nbit_grayscale_tif(file_name, stack)
    n_pages = size(stack,3) ;    
    if n_pages == 0 ,
        % no idea if this will work...
        imwrite(stack, file_name, 'tif', 'WriteMode', 'overwrite',  'Compression','none');
    else
        imwrite(stack(:, :, 1), file_name, 'tif', 'WriteMode', 'overwrite',  'Compression','none');
        for k = 2:n_pages ,
            imwrite(stack(:, :, k), file_name, 'tif', 'WriteMode', 'append',  'Compression','none');
        end
    end
end
