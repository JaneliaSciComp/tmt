function node_ids_from_chain_id = chains_from_rooted_tree(dA)
    % Given adjacency matrix dA representing a rooted tree,
    % returns a set of chains.  The first and last node of each chain is a
    % node_id into A, and each is a nexus node.  All nodes in A are
    % included in at least one chain.

%     % For debugging
%     dG = digraph(dA) ;
%     figure() ;
%     plot(dG) ;

    if isempty(dA) ,
        node_ids_from_chain_id = cell(1,0) ;
        return
    elseif isscalar(dA) ,
        % The graph has a single node
        node_ids_from_chain_id = {1} ;
        return        
    end
    
    % Find the non-root nexus nodes---each of these will be the start of a
    % chain
    in_degree_from_node_id = full(sum(dA,1)') ;
    out_degree_from_node_id = full(sum(dA,2)) ;
    is_root_from_node_id = (out_degree_from_node_id==0) ;
    is_chain_node_from_node_id = (in_degree_from_node_id==1) & (out_degree_from_node_id==1) ;
    is_nexus_from_node_id = ~is_chain_node_from_node_id ;
    is_nonroot_nexus_from_node_id = is_nexus_from_node_id & ~is_root_from_node_id ;
    distal_nexus_node_id_from_chain_id = find(is_nonroot_nexus_from_node_id) ;
    chain_count = length(distal_nexus_node_id_from_chain_id) ;
    
    % Traverse the rooted tree.  This will make lookups faster later
    root_node_id = find(is_root_from_node_id) ;
    [~,parent_node_id_from_node_id] = graphtraverse(dA', root_node_id, 'DIRECTED', true) ;  
    
    % Trace each chain from its distal nexus node to its proximal nexus
    % node
    node_ids_from_chain_id = cell(chain_count, 1) ;
    for chain_id = 1 : chain_count ,
        distal_node_id = distal_nexus_node_id_from_chain_id(chain_id) ;
        node_ids_in_this_chain  = ...
            trace_chain(distal_node_id, parent_node_id_from_node_id, is_nexus_from_node_id) ;
        node_ids_from_chain_id{chain_id} = node_ids_in_this_chain ;
    end
end



function node_ids_in_chain = trace_chain(start_node_id, parent_node_id_from_node_id, is_nexus_from_node_id)
    % Trace a chain from a start node to the next
    % nexus point (a nexus is a node with degree ~= 2).  
    %
    % On return, node_ids_in_chain contains the chain, in the order
    % tranversed, including the start node and the next most proximal nexus.
    %
    % The returned chain always contains at least two nodes.
    
    node_count = length(parent_node_id_from_node_id) ;
    allocated_chain_length = 100 ;
    node_ids_in_chain_buffer = zeros(1, allocated_chain_length) ;  % will trim later
    node_ids_in_chain_buffer(1) = start_node_id ;
    current_node_id = parent_node_id_from_node_id(start_node_id) ;
    for i = 2 : node_count ,  % this trivially guarantees eventual termination, no matter how badly I screw up
        if i>allocated_chain_length ,
            allocated_chain_length = 2*allocated_chain_length ;
            node_ids_in_chain_buffer(allocated_chain_length) = 0 ;
        end
        node_ids_in_chain_buffer(i) = current_node_id ; % add the current node to the list
        
        if is_nexus_from_node_id(current_node_id) ,
            break
        else
            % Current node is a chain node, so set up for next iteration
            current_node_id = parent_node_id_from_node_id(current_node_id) ;
        end
    end
    
    % i contains the final chain length, so trim it down
    node_ids_in_chain = node_ids_in_chain_buffer(1:i) ;
end
