function save_swc_arrays(output_folder_path, ...                         
                         forest_as_swc_arrays)
    
    % Generate colormap
    tree_count = length(forest_as_swc_arrays) ;
    color_map = jet(256) ;    
    rep_count = ceil(tree_count/size(color_map,1)) ;
    raw_color_from_tree_index = repmat(color_map, [rep_count 1]) ;
    color_from_tree_index = raw_color_from_tree_index(randperm(tree_count),:);
    
    % Create the folder if it doesn't exist
    if tree_count>0 && ~exist(output_folder_path, 'file') ,
        mkdir(output_folder_path) ;
    end    
    
    % Write each fragment to disk as a .swc file
    digits_needed_for_index = floor(log10(tree_count)) + 1 ;
    for tree_index = 1:tree_count ,
        % .swc file name
        tree_name_template = sprintf('tree-%%0%dd', digits_needed_for_index) ;  % e.g. 'tree-%04d'
        tree_name = sprintf(tree_name_template, tree_index) ;
        swc_file_name = horzcat(tree_name, '.swc') ;
        swc_file_path = fullfile(output_folder_path, swc_file_name);

        % If the output file already exists, skip it
        if exist(swc_file_path, 'file') ,
            continue ;
        end
        
        % Get the centerpoints for this neuron
        tree_as_swc_array = forest_as_swc_arrays{tree_index} ;
        tree_color = color_from_tree_index(tree_index, :) ;
        save_swc(swc_file_path, tree_as_swc_array, tree_name, tree_color) ;
    end
end
