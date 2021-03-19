function [result, new_node_index_from_node_index] = interpolate_named_tree(named_tree, maximum_spacing)
    % Do piecewise linear interpolation on tree, to make it so that
    % all edges are no longer than maximum_spacing

    xyz_from_node_index = named_tree.xyz ;
    parent_from_node_index = named_tree.parent ;
    children_from_node_index = invert_parent_from_node_id(parent_from_node_index) ;
    
    if parent_from_node_index(1) ~= -1 ,
        error('named_tree has to be topologically sorted')
    end
    
    parent_from_new_node_index = -1 ;
    xyz_from_new_node_index = xyz_from_node_index(1,:) ;
    
    node_count = length(parent_from_node_index) ;
    new_node_index_from_node_index = zeros(node_count, 1) ;
    new_node_index_from_node_index(1) = 1 ;  % the roots of both trees are at index 1
    new_node_count_so_far = 1 ;
    for parent_node_index = 1 : node_count ,
        mirror_of_parent_node_index = new_node_index_from_node_index(parent_node_index) ;  % this is an index in the interpolated tree
        parent_node_xyz = xyz_from_node_index(parent_node_index  ,:) ;
        children_node_indices = children_from_node_index{parent_node_index} ;
        for i = 1 : length(children_node_indices) ,
            child_node_index = children_node_indices(i) ;
            child_node_xyz   = xyz_from_node_index(child_node_index,:) ;
            
%             if child_node_index== 3702 && parent_node_index==3701 ,
%                 keyboard
%             end
            
            dxyz = child_node_xyz - parent_node_xyz ;
            edge_length = sqrt(sum(dxyz.^2)) ;
            if edge_length <= maximum_spacing ,
                % the easy case---no interpolation needed
                new_node_index = new_node_count_so_far+1 ;
                xyz_from_new_node_index(new_node_index,:) = child_node_xyz ;                
                parent_from_new_node_index(new_node_index) = mirror_of_parent_node_index ;
                new_node_index_from_node_index(child_node_index) = new_node_index ;
                new_node_count_so_far = new_node_index ;
            else
                % the harder case---need to interpolate
                new_edge_count_for_this_edge = ceil(edge_length/maximum_spacing) ;
                new_node_indices = (new_node_count_so_far+1 : new_node_count_so_far+new_edge_count_for_this_edge)' ;
                new_edge_length = edge_length/new_edge_count_for_this_edge ;
                scaled_dxyz = new_edge_length/edge_length * dxyz ;
                new_xyzs = parent_node_xyz + scaled_dxyz .* (1:new_edge_count_for_this_edge)' ;
                xyz_from_new_node_index(new_node_indices,:) = new_xyzs ;
                new_node_index_from_node_index(child_node_index) = new_node_indices(end) ;
                parent_from_new_node_index(new_node_indices) = ...
                    [ mirror_of_parent_node_index ; ...
                      new_node_indices(1:end-1) ] ;                      
                new_node_count_so_far = new_node_indices(end) ;            
            end
        end
    end
    
    new_node_count = new_node_count_so_far ;
    r = ones(new_node_count, 1) ;  % don't use this currently
    tag_code = zeros(new_node_count, 1) ;  % don't use this either
    result = new_named_tree(named_tree.name, named_tree.color, xyz_from_new_node_index, r, parent_from_new_node_index, tag_code) ;    
end











