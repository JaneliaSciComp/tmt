function [A_pruned, xyz_pruned, node_id_from_pruned_node_index] = ...
        prune_tree_with_id_tracking(A_tree, xyz_tree, node_id_from_tree_node_index, length_threshold, do_visualize)  %#ok<INUSD>
    % The "in_place" just means that the result is in terms of the same
    % nodes as input.
    node_count = size(xyz_tree, 1) ;
    is_retained_from_node_index = true(node_count, 1) ;
    did_prune_some = true ;  % just to get prune_tree_some() to be called at least once
    while did_prune_some ,
        [is_retained_from_node_index, did_prune_some] = prune_tree_some(is_retained_from_node_index, A_tree, xyz_tree, length_threshold) ;
%         if do_visualize ,
%             hold on
%             gplot3(A_result, xyz_result);
%             drawnow
%         end
    end
    A_pruned = A_tree(is_retained_from_node_index, is_retained_from_node_index) ;
    xyz_pruned = xyz_tree(is_retained_from_node_index, :) ;
    node_id_from_pruned_node_index = node_id_from_tree_node_index(is_retained_from_node_index) ;
end



function [is_retained_from_node_id_output, did_prune_some] = prune_tree_some(is_retained_from_node_id_input, A_tree, xyz, length_threshold)
    % length_threshold should be in um.  Leaf chains shorter than that will be
    % trimmed off.
    
    % Get the chains, each of which will start at a leaf node or a branch
    % node, and all the leaf nodes will be the first element of some chain,
    % unless the tree is a chain, in which case there will only one chain,
    % and it will start with a leaf node.
    A_retained = A_tree(is_retained_from_node_id_input, is_retained_from_node_id_input) ;
    chains_in_terms_of_retained_node_indices = chains_from_tree(A_retained) ;
    chain_count = length(chains_in_terms_of_retained_node_indices) ;

    % If the tree is a single chain, don't bother to prune
    if chain_count == 1 ,
        is_retained_from_node_id_output = is_retained_from_node_id_input ;
        did_prune_some = false ;
        return
    end
    
    % If get here, the tree is not just a single chain

    % Put the chains in terms of node IDs
    node_count = length(is_retained_from_node_id_input) ;
    node_id_from_node_id = (1:node_count)' ; 
    node_id_from_retained_node_index = node_id_from_node_id(is_retained_from_node_id_input) ;
    chains = cellfun(@(chain_in_terms_of_retained_node_indices)(node_id_from_retained_node_index(chain_in_terms_of_retained_node_indices)), ...
                     chains_in_terms_of_retained_node_indices, ...
                     'UniformOutput', false) ;  % these are in terms of the node_ids
    
    % Get just the chains that start with leaf nodes
    degree_from_node_id = full(sum(A_tree)) ;
    is_leaf_node = (degree_from_node_id==1) ;
    do_keep_chain = cellfun(@(chain)(is_leaf_node(chain(1))), chains) ;
    leaf_chains = chains(do_keep_chain) ;    
    leaf_chain_count = length(leaf_chains) ;
        
    % Since the tree is not a simple chain, note that each leaf chain must
    % end in a branch node, b/c chains_from_tree() guarantees this.
    
    % For each leaf chain, get its length and the end node id.
    length_from_leaf_chain_index = zeros(leaf_chain_count, 1) ;
    branch_node_id_from_leaf_chain_index = zeros(leaf_chain_count, 1) ;
    for i = 1 : leaf_chain_count ,
        chain = leaf_chains{i} ;
        chain_length = chain_length_from_chain(chain, xyz) ;
        length_from_leaf_chain_index(i) = chain_length ;
        branch_node_id_from_leaf_chain_index(i) = chain(end) ;  % this much be a branch node
    end

    % If there are multiple too-short leaf chains coming out of a single branch
    % node, we want to spare the longest of these, in hopes that it's a
    % valid on even though others are spurs.

    % Group the leaf chains by branch node id
    leaf_chain_index_from_leaf_chain_index = (1:leaf_chain_count) ;
    [leaf_chain_indices_from_branch_index, branch_node_id_from_branch_index] = ...
        bag_items_by_id(branch_node_id_from_leaf_chain_index, leaf_chain_index_from_leaf_chain_index) ;
    unique_branch_node_count = length(branch_node_id_from_branch_index) ;  % How many unique branch nodes the leaf chains go into

    % For each unique branch node, mark some or the associated leaf
    % chains as being doomed
    is_doomed_from_leaf_chain_index = false(leaf_chain_count, 1) ;        
    for branch_index = 1 : unique_branch_node_count ,
        leaf_chain_indices = leaf_chain_indices_from_branch_index{branch_index} ;
        leaf_chain_lengths = length_from_leaf_chain_index(leaf_chain_indices) ;
        is_leaf_chain_stubby = (leaf_chain_lengths < length_threshold) ;
        if ~isscalar(leaf_chain_indices) && all(is_leaf_chain_stubby) ,
            % don't want to delete them all---spare the longest one
            [~, i_max] = max(leaf_chain_lengths) ;
            is_leaf_chain_stubby(i_max) = false ;
        end
        % Delete the stubby leaf nodes
        stubby_leaf_chain_indices = leaf_chain_indices(is_leaf_chain_stubby) ;
        is_doomed_from_leaf_chain_index(stubby_leaf_chain_indices) = true ;            
    end

    % Mark all nodes of the doomed leaf node chains as doomed
    %node_count = length(degree_from_node_id) ;
    is_doomed_from_node_id = false(node_count, 1) ;
    for i = 1 : leaf_chain_count ,
         if is_doomed_from_leaf_chain_index(i) ,
             chain = leaf_chains{i} ;
             chain_without_end = chain(1:end-1) ;  % don't want to delete the branch point!
             is_doomed_from_node_id(chain_without_end) = true ;
         end
    end

    % Populate the outputs.
    is_retained_from_node_id_output = is_retained_from_node_id_input & ~is_doomed_from_node_id ;
    did_prune_some = any(is_doomed_from_node_id) ;
end
