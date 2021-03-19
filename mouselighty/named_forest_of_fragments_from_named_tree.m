function result = named_forest_of_fragments_from_named_tree(named_tree, ...
                                                            minimum_centerpoint_count_per_fragment, ...
                                                            bounding_box_low_corner_xyz, ...
                                                            bounding_box_high_corner_xyz)

    % Extract tree information                                          
    xyz = named_tree.xyz ;  % um
    r = named_tree.r ;
    d = named_tree.tag_code ;
    
    dA = directed_adjacency_from_named_tree(named_tree) ;  % directed adjacency
    chains = chains_from_rooted_tree(dA) ;    
    %L = getBranches_old(dA) ;
    maximum_fragment_count = length(chains) ;
    
    % Generate colormap
    raw_color_from_fragment_id = jet(maximum_fragment_count);
    color_from_fragment_id = raw_color_from_fragment_id(randperm(maximum_fragment_count),:) ;
    
    digits_needed_for_fragment_index = floor(log10(maximum_fragment_count)) + 1 ;
    fragment_name_template = sprintf('%s-branch-%%0%dd', named_tree.name, digits_needed_for_fragment_index) ;  % e.g. 'tree-%04d'
    
    % Pre-allocate array to hold the fragments
    is_fragment_valid = false(1, maximum_fragment_count) ;
    raw_fragments_as_named_trees = preallocate_forest_of_named_trees([1 maximum_fragment_count]) ;
    
    % Write each fragment to disk as a .swc file
    parfor fragment_id = 1:maximum_fragment_count ,
        tree_node_ids_in_chain = chains{fragment_id} ;
        if maximum_fragment_count>1 ,
            tree_node_ids_in_fragment = tree_node_ids_in_chain(1:end-1) ;  % trim one end to leave some space at branch points
        else
            tree_node_ids_in_fragment = tree_node_ids_in_chain ;  % If the tree is just a single chain, leave ends alone
        end            
        if isempty(tree_node_ids_in_fragment)
            continue
        end        
        
        % .swc file name
%        fragment_name = sprintf(fragment_name_template, fragment_id) ;
%         fragment_swc_file_name = sprintf('%s.swc', fragment_name) ;
%         fragment_swc_file_path = fullfile(fragment_output_folder_path, fragment_swc_file_name);
% 
%         % If the output file already exists, skip it
%         if exist(fragment_swc_file_path, 'file') ,
%             continue ;
%         end
        
        % Get the centerpoints for this fragment
        xyz_this_fragment = xyz(tree_node_ids_in_fragment,:) ;
        r_this_fragment = r(tree_node_ids_in_fragment) ;
        d_this_fragment = d(tree_node_ids_in_fragment) ;

        % Don't write an swc for fragments with too few centerpoints
        fragment_node_count = size(xyz_this_fragment,1) ;
        if fragment_node_count < minimum_centerpoint_count_per_fragment ,
            continue
        end
        
        % Center centerpoint coordinates on the center of mass
        fragment_centroid_xyz = mean(xyz_this_fragment, 1) ;        
        %xyz_this_fragment_centered = bsxfun(@minus, xyz_this_fragment, fragment_centroid_xyz) ;
        
        % Don't write fragments with centroids outside the bounding box
        if all(bounding_box_low_corner_xyz <= fragment_centroid_xyz) && all(fragment_centroid_xyz <= bounding_box_high_corner_xyz) ,
            % do nothing, fragment centroid is within bouding box
        else
            continue
        end

        % Make a named tree version of the fragment
        parent_ids_except_first = (1:(fragment_node_count-1))' ;  % parent of centerpoint 2 is 1, parent of centerpoint 3 is 2, etc.
        parent_ids = vertcat(-1, parent_ids_except_first) ;  % .swc says the root should have parent == -1        
        fragment_name = sprintf(fragment_name_template, fragment_id) ;
        fragment_color = color_from_fragment_id(fragment_id,:) ;
        fragment_as_named_tree = new_named_tree(fragment_name, fragment_color, xyz_this_fragment, r_this_fragment, parent_ids, d_this_fragment) ;
        
        % Add to forest
        raw_fragments_as_named_trees(fragment_id) = fragment_as_named_tree ;
        is_fragment_valid(fragment_id) = true ;
    end
    
    % trim the array
    result = raw_fragments_as_named_trees(is_fragment_valid) ;    
end
