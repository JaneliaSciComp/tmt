function result = index_using_array(A, ijk)
    cijk = num2cell(ijk) ;
    cijk_as_row = cijk(:).' ;
    result = A(cijk_as_row{:}) ;
end
