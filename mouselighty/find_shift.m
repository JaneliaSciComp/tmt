function [rounded_shift, shift] = find_shift(stack, min_shift, max_shift, do_3d, do_run_in_debug_mode)
    if do_3d ,
        im1 = double(stack(1:2:end,:,:)) ;
        im2 = double(stack(2:2:end,:,:)) ;
        example_image = double(stack(:,:,round((end+1)/2))) ;
    else
        mip = double(max(stack,[],3)) ;
        im1 = mip(1:2:end,:) ;
        im2 = mip(2:2:end,:) ;
        example_image = mip ;
    end

    if size(im1,1) > size(im2,1) ,
        im1(end,:,:) = [] ;
    end
    
    norms = zeros(1,max_shift-min_shift+1) ;
    searchinterval = min_shift:max_shift ;

    im1_serial = im1(:) ;
    for iter = 1 :  length(searchinterval) ,
        shift = searchinterval(iter) ;
        shifted_im2 = circshift(im2, shift, 2) ;
        %corr = im1 .* shifted_im2 ;
        %norms(iter) = norm(corr)/(norm(im1)*norm(im2)) ;
        Sigma = corrcoef(im1_serial, shifted_im2(:)) ;
        norms(iter) = Sigma(1,2) ;
    end
    
    if all(isnan(norms)) 
        % This can happen if the stack, after binarizing and MIP-ing, is all the same
        % value.  This only seems to happen for stacks with basically nothing in them,
        % so just use a zero shift
        shift = 0 ;
        if do_run_in_debug_mode ,
            % Do this stuff in case
            shift_from_grid_index = linspace(min_shift, max_shift, 50*length(searchinterval)+1) ;
            norms_from_grid_index = nan(size(shift_from_grid_index)) ;
        end
    else    
        shift_from_grid_index = linspace(min_shift, max_shift, 50*length(searchinterval)+1) ;
        norms_from_grid_index = interp1(searchinterval, norms, shift_from_grid_index, 'spline') ;
        norm_at_zero = norms_from_grid_index(shift_from_grid_index==0) ;
        [~, grid_index_at_max] = max(norms_from_grid_index) ;
        norm_at_optimal_shift = norms_from_grid_index(grid_index_at_max) ;
        minimum_margin = 0.001 ;
        if norm_at_optimal_shift-minimum_margin<=norm_at_zero && norm_at_zero<norm_at_optimal_shift+minimum_margin ,
            % the norm at the optimal shift is not meanigfully different from the norm at
            % zero shift
            shift = 0 ;
        else
            % the norm at the optimal shift *is* meanigfully different from the norm at
            % zero shift
            shift = shift_from_grid_index(grid_index_at_max) ;
        end
    end
    
    if do_run_in_debug_mode ,
        f1 = figure() ;
        a1 = axes(f1) ;
        imshow(example_image, 'Parent', a1) ;
        drawnow() ;
        
        f2 = figure() ;
        a2 = axes(f2) ;
        plot(a2, searchinterval, norms, 'r+', shift_from_grid_index, norms_from_grid_index, 'g-') ;
        title(a2, sprintf('Optimal: %g', shift)) ;
        drawnow() ;
    end
    
    rounded_shift = round(shift) ;
end
