function result = are_paired_descriptors_close_enough(pd1, pd2)
    % The order of the pairs can be different between the two versions, so sort the
    % rows to deal with this
    [x1,ix1] = sortrows(pd1.X) ;
    y1_raw = pd1.Y ;
    y1 = y1_raw(ix1,:) ;
    
    [x2,ix2] = sortrows(pd2.X) ;
    y2_raw = pd2.Y ;
    y2 = y2_raw(ix2,:) ;   
    
    result = size(x1,1)==size(x2,1) && size(y1,1)==size(y2,1) && isequal(x1,x2) && isequal(y1,y2) ;    
end
