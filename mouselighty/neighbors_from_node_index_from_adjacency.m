function result = neighbors_from_node_index_from_adjacency(A)
    [is,js] = find(A) ;
    node_count = size(A,1) ;
    result = cell(node_count,1) ;
    edge_count = length(is) ;
    for edge_index = 1: edge_count ,
        i = is(edge_index) ;
        j = js(edge_index) ;
        result{i}(1,end+1) = j ;
    end
end
