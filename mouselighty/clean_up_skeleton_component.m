function [A_decimated, xyz_from_decimated_node_index] = ...
        clean_up_skeleton_component(A_input, ...
                                    xyz_from_input_node_index, ...
                                    size_threshold, ...
                                    smoothing_filter_width, ...
                                    length_threshold, ...
                                    do_visualize, ...
                                    sampling_interval)

    % Plot the input                                                       
    if do_visualize ,
        f = figure('Color', 'w') ;
        ax = axes(f) ;
        l0 = gplot3(ax, A_input, xyz_from_input_node_index, 'b') ;  % blue
        hold(ax, 'on') ;
        drawnow
    end
                                                       
    % Get a spanning tree, and the deleted edges
    input_node_count = size(A_input, 1) ;
    input_node_index_from_input_node_index = (1:input_node_count)' ;
    degree = full(sum(A_input)) ;
    degree_modified = degree ;
    degree_modified(degree==0) = +inf ;
    [~, min_degree_node_index] = min(degree_modified) ;  % min degree is hopefully one, but sometimes not possible (e.g. if graph is just a loop)
    dA_spanning = rooted_tree_from_connected_graph(A_input, min_degree_node_index) ;
    A_spanning = max(dA_spanning, dA_spanning') ;
    A_leftovers = A_input - A_spanning ;  % All the edges that were deleted from A_input to make it into a tree
    
    if do_visualize
        l1 = gplot3(ax, A_spanning, xyz_from_input_node_index, 'Color', [0 0.5 0]) ;   % green
        drawnow
    end
    
    %%
    [A_pruned, xyz_from_pruned_node_index, input_node_index_from_pruned_node_index] = ...
        prune_tree_with_id_tracking(A_spanning, xyz_from_input_node_index, input_node_index_from_input_node_index, length_threshold, do_visualize) ;    
    if do_visualize
        l2 = gplot3(ax, A_pruned, xyz_from_pruned_node_index, 'r') ;  % red
        drawnow
    end
    
    %%
    pruned_node_count = length(input_node_index_from_pruned_node_index) ;    
    if pruned_node_count < size_threshold ,
%         fprintf('Component with id %d fails to meet the size threshold (%d) after pruning, so discarding.  (It contains %d nodes.)\n', ...
%                 component_id, ...
%                 size_threshold, ...
%                 pruned_node_count) ;
        A_decimated = sparse([]) ;
        xyz_from_decimated_node_index = zeros(0, 3) ;
        return
    end

    % Decompose tree into chains
    pruned_as_chains = chains_from_tree(A_pruned, input_node_index_from_pruned_node_index) ;

    % Smooth the z coords of chain nodes
    smoothed_xyz_from_pruned_node_index = smooth_chains(pruned_as_chains, xyz_from_pruned_node_index, smoothing_filter_width) ;
    %xyz_smoothed = xyz_pruned ;

    % Visualize the smoothed tree
    if do_visualize        
        l3 = gplot3(ax, A_pruned, smoothed_xyz_from_pruned_node_index, 'Color', [1 2/3 0]) ;   % orange
        drawnow
    end  
        
    % Decimate chains
    G_decimated_as_chains_using_pruned_node_indices = decimate_chains(pruned_as_chains, smoothed_xyz_from_pruned_node_index, sampling_interval) ;
    
    % Convert chains to edges
    G_decimated_as_edges_using_pruned_node_indices = edges_from_chains(G_decimated_as_chains_using_pruned_node_indices) ;

    % Defragment the node ids
    [G_decimated_as_edges_using_decimated_node_indices, xyz_from_decimated_node_index, pruned_node_index_from_decimated_node_index] = ...
        defragment_node_ids_in_edges(G_decimated_as_edges_using_pruned_node_indices, smoothed_xyz_from_pruned_node_index) ;
    input_node_index_from_decimated_node_index = input_node_index_from_pruned_node_index(pruned_node_index_from_decimated_node_index) ;
    
    % Convert edges to (sparse) adjacency
    decimated_node_count = length(pruned_node_index_from_decimated_node_index) ;
    A_decimated = undirected_adjacency_from_edges(G_decimated_as_edges_using_decimated_node_indices, decimated_node_count) ;    
    
    % Visualize the decimated tree
    if do_visualize
        l4 = gplot3(ax, A_decimated, xyz_from_decimated_node_index, 'Color', [0.6 0 0.8]) ;   % purple
        legend([l0 l1 l2 l3 l4], {'original', 'tree', 'pruned', 'smoothed', 'decimated'}) ;        
        axis(ax, 'vis3d') ;
        %title(ax, sprintf('Component %d', component_id)) ;
        xlabel(ax, 'x (um)') ;
        ylabel(ax, 'y (um)') ;
        zlabel(ax, 'z (um)') ;                
        drawnow
    end

    % Compute  
    is_in_decimated_from_input_node_index = false(input_node_count, 1) ;
    is_in_decimated_from_input_node_index(input_node_index_from_decimated_node_index) = true ;
    A_leftovers_from_decimated_node_index = A_leftovers(is_in_decimated_from_input_node_index, is_in_decimated_from_input_node_index) ;
    
    
    
    
    
%     % Convert to a named tree
%     digits_needed_for_index = floor(log10(max_component_id)) + 1 ;
%     tree_name_template = sprintf('auto-cc-%%0%dd', digits_needed_for_index) ;  % e.g. 'tree-%04d'
%     tree_name = sprintf(tree_name_template, component_id) ;
%     A_result = named_tree_from_undirected_graph(A_decimated, xyz_result, tree_name) ;    
    
%     % Compute the output file path
%     tree_mat_file_name = sprintf('%s.mat', tree_name) ;
%     tree_mat_file_path = fullfile(output_folder_path, tree_mat_file_name);    
    
    % Write full tree as a .mat file
    %save_named_tree_as_mat(tree_mat_file_path, named_tree) ;
end
