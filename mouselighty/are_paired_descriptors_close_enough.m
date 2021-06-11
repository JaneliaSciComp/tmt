function result = are_paired_descriptors_close_enough(pd1, pd2)
    x1 = pd1.X ;
    x2 = pd2.X ;
    y1 = pd1.Y ;
    y2 = pd2.Y ;
    result = size(x1,1)==size(x2,1) && size(y1,1)==size(y2,1) && isequal(x1,x2) && isequal(y1,y2) ;    
end
