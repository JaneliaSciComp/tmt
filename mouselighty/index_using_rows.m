function result = index_using_rows(A, ijks)
    row_count = size(ijks, 1) ;
    result = zeros(row_count, 1) ;
    for row_index = 1 : row_count ,
        ijk = ijks(row_index,:) ;
        result(row_index) = A(ijk(1), ijk(2), ijk(3)) ;
    end
end
