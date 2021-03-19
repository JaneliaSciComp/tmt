function [f, a, im] = plot_mip(stack_or_mip, stack_origin_xyz, stack_spacing_xyz, name, color_map)
    if ismatrix(stack_or_mip) ,
        mip = stack_or_mip ;
    else
        stack = stack_or_mip ;
        mip = max(stack, [], 3) ;
    end

    if isa(mip, 'uint16') ,
        mip = double(mip) ;
    end
    
    is_name =  exist('name', 'var') && ~isempty(name) ;
    
    if ~exist('color_map', 'var') || isempty(color_map) ,
        color_map = gray(256) ;
    end
    
    mip_shape_ji = size(mip) ;
    mip_shape_ij = mip_shape_ji([2 1]) ;
    mip_origin_xy = stack_origin_xyz(1:2) ;
    mip_far_corner_xy = mip_origin_xy + stack_spacing_xyz(1:2) .* (mip_shape_ij-1) ;
    
    if is_name ,        
        f = figure('color', 'w', 'name', name) ;
    else
        f = figure('color', 'w') ;
    end
    a = axes(f, 'YDir', 'reverse') ;
    im = image(a, 'CData', mip, ...
                  'XData', [mip_origin_xy(1) mip_far_corner_xy(1)], ...
                  'YData', [mip_origin_xy(2) mip_far_corner_xy(2)], ...
                  'CDataMapping', 'scaled') ;
    xlim([mip_origin_xy(1) mip_far_corner_xy(1)] + stack_spacing_xyz(1)/2*[-1 +1]) ;
    ylim([mip_origin_xy(2) mip_far_corner_xy(2)] + stack_spacing_xyz(2)/2*[-1 +1]) ;
    colormap(color_map) ;
    axis image    
    xlabel('x (um)') ;
    ylabel('y (um)') ;
    colorbar
end
