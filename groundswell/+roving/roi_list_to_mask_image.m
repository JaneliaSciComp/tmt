function mask_image = roi_list_to_mask_image(roi_list, n_rows, n_cols)    
    % get length
    n_rois = length(roi_list) ;
    
    % translate the borders into masks
    mask_image = false(n_rows, n_cols) ;
    template = zeros(n_rows, n_cols) ;
    for k = 1:n_rois ,
        this_border = roi_list(k).border ;
        x = this_border(1,:) ;
        y = this_border(2,:) ;
        single_roi_mask_image = roipoly(template,x,y) ;
        mask_image = mask_image | single_roi_mask_image ;
    end    
end
