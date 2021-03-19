function save_skeleton_graph_as_text(file_name, skeleton_ijks, neighbors_from_node_index) 
    fid = fopen(file_name, 'wt') ;
    if fid<0 ,
        error('Unable to open file %s for writing', file_name) ;
    end
    cleaner = onCleanup(@()(fclose(fid))) ;
    %neighbors_from_node_index = neighbors_from_node_index_from_adjacency(A) ;
    node_count = size(skeleton_ijks, 1) ;
    for node_index = 1 : node_count ,
        ijk = skeleton_ijks(node_index,:) ;
        %neighbor_node_indices = skeleton_graph.neighbors(node_index)' ;  % want as row vector
        %neighbor_node_indices_check = find(A(node_index,:)) ;
        neighbor_node_indices = neighbors_from_node_index{node_index} ;
        %assert(isempty(setdiff(neighbor_node_indices_check, neighbor_node_indices))) ;
        numbers_to_print = horzcat(node_index, ijk, neighbor_node_indices) ;
        fprintf(fid, '%d ',numbers_to_print) ;
        fprintf(fid, '\n') ;
    end
    % fclose() handled by cleaner
end
