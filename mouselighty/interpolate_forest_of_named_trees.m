function result = interpolate_forest_of_named_trees(forest_of_named_trees, maximum_spacing)
    % Do piecewise linear interpolation on tree, to make it so that
    % all edges are no longer than maximum_spacing

    result = preallocate_forest_of_named_trees(size(forest_of_named_trees)) ;
    tree_count = length(forest_of_named_trees) ;
    for i = 1 : tree_count ,
        result(i) = interpolate_named_tree(forest_of_named_trees(i), maximum_spacing) ;
    end
end
