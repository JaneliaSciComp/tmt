function [xyz_from_node_id, tree_id_from_node_id] = point_cloud_from_forest_as_named_trees(forest_as_named_trees)
    % Extract the xyz coordinate of each node in a forst.
    % Also returns a look-up array that reveals the tree index for each point in the
    % cloud.
    % The forest is a cell array, each element an swc array
    tree_count = length(forest_as_named_trees) ;
    node_count_from_tree_id = arrayfun(@(tree)(size(tree.parent,1)), forest_as_named_trees) ;
    total_node_count = sum(node_count_from_tree_id) ;
    xyz_from_node_id = zeros(total_node_count,3) ;
    tree_id_from_node_id = zeros(total_node_count,1) ;
    last_node_id = 0 ;
    for tree_id = 1:tree_count ,
        tree = forest_as_named_trees(tree_id) ;
        xyzs = tree.xyz ;
        node_count = size(xyzs, 1) ;
        xyz_from_node_id(last_node_id+1:last_node_id+node_count,:) = xyzs ;
        tree_id_from_node_id(last_node_id+1:last_node_id+node_count) = tree_id ;
        last_node_id = last_node_id+node_count ;
    end    
end
