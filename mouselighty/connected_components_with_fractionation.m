function [sorted_components, sorted_size_per_component] = connected_components_with_fractionation(G, maximum_component_size)
    % Determine connected components, then optionally use spectral graph
    % partitioning to get all the big components down to a managable size.
    
    [components, size_per_component] = conncomp(G,'OutputForm','cell') ;  % cell array, each element a 1d array of node ids in G    
    [sorted_components, sorted_size_per_component] = sort_components_by_size(components, size_per_component) ;
    if ~isempty(sorted_components) ,
        while sorted_size_per_component(1) > maximum_component_size ,
            node_ids = sorted_components{1} ;
            G_component= G.subgraph(node_ids) ;
            L_component = G_component.laplacian ;
            [V,~] = eigs(L_component, 2, 'smallestabs') ;
            w = V(:,2) ;  % Fiedler vector
            is_right = (w>=0) ; 
            is_left = ~is_right ;
            right_node_ids = node_ids(is_right) ;
            left_node_ids = node_ids(is_left) ;
            right_size = length(right_node_ids) ;
            left_size = length(left_node_ids) ;
            components = [{right_node_ids} {left_node_ids} sorted_components(2:end)] ;
            size_per_component = [right_size left_size sorted_size_per_component(2:end)] ;
            [sorted_components, sorted_size_per_component] = sort_components_by_size(components, size_per_component) ;
        end
    end
end


