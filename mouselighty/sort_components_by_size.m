function [sorted_components, size_per_component] = sort_components_by_size(components, size_per_component)
    % sort components by size, with largest ones first
    [size_per_component,js] = sort(size_per_component, 'descend') ;
    sorted_components = components(js) ;
end
