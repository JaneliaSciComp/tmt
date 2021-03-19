function [A, xyz_from_node_id, tree_index_from_node_id] = adjacency_from_forest_as_named_trees(forest_as_named_trees)
    [dA, xyz_from_node_id, tree_index_from_node_id] = dA_from_forest_of_named_trees(forest_as_named_trees) ;
    A = max(dA, dA') ;
end
