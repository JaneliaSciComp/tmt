function node_ids_from_chain_index = chains_from_rooted_tree_with_id_tracking(dA, node_id_from_node_index)
    % Given adjacency matrix dA representing a rooted tree,
    % returns a set of chains.  The first and last node of each chain is a
    % node_id into A, and each is a nexus node.  All nodes in A are
    % included in at least one chain.

%     % For debugging
%     dG = digraph(dA) ;
%     figure() ;
%     plot(dG) ;

    node_count = size(dA, 1) ;

    if node_count == 0 ,
        node_ids_from_chain_index = cell(1,0) ;
        return
    elseif node_count == 1 ,
        % The graph has a single node
        node_ids_from_chain_index = {1} ;
        return        
    end
    
    % Find the non-root nexus nodes---each of these will be the start of a
    % chain
    in_degree_from_node_index = full(sum(dA,1)') ;
    out_degree_from_node_index = full(sum(dA,2)) ;
    is_root_from_node_index = (out_degree_from_node_index==0) ;
    is_limb_node_from_node_index = (in_degree_from_node_index==1) & (out_degree_from_node_index==1) ;
    is_nonlimb_from_node_index = ~is_limb_node_from_node_index ;
    is_nonroot_nonlimb_from_node_index = is_nonlimb_from_node_index & ~is_root_from_node_index ;
    distal_nonlimb_node_index_from_chain_index = find(is_nonroot_nonlimb_from_node_index) ;
    chain_count = length(distal_nonlimb_node_index_from_chain_index) ;
    
    % Traverse the rooted tree.  This will make lookups faster later
    root_node_index = find(is_root_from_node_index) ;
    [~,parent_node_index_from_node_index] = graphtraverse(dA', root_node_index, 'DIRECTED', true) ;  
    
    % Trace each chain from its distal nexus node to its proximal nexus
    % node
    node_ids_from_chain_index = cell(chain_count, 1) ;
    for chain_index = 1 : chain_count ,
        distal_node_index = distal_nonlimb_node_index_from_chain_index(chain_index) ;
        node_indices_in_this_chain  = ...
            trace_chain(distal_node_index, parent_node_index_from_node_index, is_nonlimb_from_node_index) ;
        node_ids_in_this_chain = node_id_from_node_index(node_indices_in_this_chain) ;
        node_ids_from_chain_index{chain_index} = node_ids_in_this_chain ;
    end
end



function node_indices_in_chain = trace_chain(start_node_index, parent_node_index_from_node_index, is_nexus_from_node_index)
    % Trace a chain from a start node to the next
    % nexus point (a nexus is a node with degree ~= 2).  
    %
    % On return, node_indices_in_chain contains the chain, in the order
    % tranversed, including the start node and the next most proximal nexus.
    %
    % The returned chain always contains at least two nodes.
    
    node_count = length(parent_node_index_from_node_index) ;
    allocated_chain_length = 100 ;
    node_indices_in_chain_buffer = zeros(1, allocated_chain_length) ;  % will trim later
    node_indices_in_chain_buffer(1) = start_node_index ;
    current_node_index = parent_node_index_from_node_index(start_node_index) ;
    for i = 2 : node_count ,  % this trivially guarantees eventual termination, no matter how badly I screw up
        if i>allocated_chain_length ,
            allocated_chain_length = 2*allocated_chain_length ;
            node_indices_in_chain_buffer(allocated_chain_length) = 0 ;
        end
        node_indices_in_chain_buffer(i) = current_node_index ; % add the current node to the list
        
        if is_nexus_from_node_index(current_node_index) ,
            break
        else
            % Current node is a chain node, so set up for next iteration
            current_node_index = parent_node_index_from_node_index(current_node_index) ;
        end
    end
    
    % i contains the final chain length, so trim it down
    node_indices_in_chain = node_indices_in_chain_buffer(1:i) ;
end
