function clean_up_skeleton_graph(skeleton_graph, ...
                                 skeleton_xyzs, ...
                                 output_folder_path, ...
                                 size_threshold, ...
                                 smoothing_filter_width, ...
                                 length_threshold, ...
                                 do_visualize, ...
                                 sampling_interval, ...
                                 maximum_core_count_desired, ...
                                 do_force_computations, ...
                                 do_all_computations_serially)

    % Extract parameters from p-map .h5 file
    %origin_heckbertian = h5read(whole_brain_h5_p_map_file_path, [whole_brain_h5_p_map_properties_group_path,'/origin'])/1000 ;  % um
    %spacing_at_top_level = h5read(whole_brain_h5_p_map_file_path, [whole_brain_h5_p_map_properties_group_path,'/spacing'])/1000 ;  % um
    %levels_below_top_level = h5read(whole_brain_h5_p_map_file_path, [whole_brain_h5_p_map_properties_group_path,'/level']) ;

    % Break out the 'params'
    %spacing_at_full_zoom = spacing_at_top_level/2^levels_below_top_level ;  % in um, at highest zoom level

    % Create the output folder, if needed
    if ~exist(output_folder_path, 'file') ,
        mkdir(output_folder_path) ;
    end

    % Load the skeleton graph
    %load(skeleton_graph_mat_file_path, 'skeleton_graph', 'skeleton_ijks') ;   

    % "components" are sometimes called "connected components"
    %[components, size_from_component_id] = conncomp(G,'OutputForm','cell') ;  % cell array, each element a 1d array of node ids in G
    fractionated_components_file_path = fullfile(output_folder_path, 'fractionated_components.mat') ;
    if exist(fractionated_components_file_path, 'file') && ~do_force_computations ,
        load(fractionated_components_file_path, 'component_from_component_id', 'size_from_component_id', 'maximum_component_size') ;
    else
        %maximum_component_size = inf ;
        maximum_component_size = 10e6 ;
        [component_from_component_id, size_from_component_id] = connected_components_with_fractionation(skeleton_graph, maximum_component_size) ;
        %[component_from_component_id, size_from_component_id] = connected_components_without_fractionation(skeleton_graph) ;
           % note that components are sort by size, largest first
        save(fractionated_components_file_path, 'component_from_component_id', 'size_from_component_id', 'maximum_component_size', '-v7.3') ;
    end
    component_count = length(component_from_component_id) ;
    max_component_id = component_count ;
    component_id_from_component_id = (1:component_count)' ;
    fprintf('There are %d components.\n', component_count) ;
    if component_count > 0 ,
        fprintf('The largest component contains %d nodes.\n', size_from_component_id(1)) ;
    end

    % This will be useful in various places, so do it once here    
    A = skeleton_graph.adjacency ;  % adjacency matrix, node_count x node_count, with zeros on the diagonal

    % This too
    %skeleton_xyzs = origin_heckbertian + spacing_at_full_zoom .* (skeleton_ijks-0.5) ;  
      % NB: Using Erhan-style coords, here, to match the existing code.
      % Also, Erhan-style coords are Heckbertian, which I think are better
      % anyway.
    %clear skeleton_ijks

    runtic = tic;

    % Create the output folder if it doesn't exist
    if ~exist(output_folder_path, 'dir') ,
        mkdir(output_folder_path) ;
    end

    % Don't process ones that are too small
    fprintf('Filtering out components smaller than %d nodes...\n', size_threshold) ;
    is_big_enough = (size_from_component_id>size_threshold) ;
    component_id_from_processing_index = component_id_from_component_id(is_big_enough) ;    
    components_to_process_count = length(component_id_from_processing_index) ;    
    fprintf('%d components left.\n', components_to_process_count) ;

    % Figure out which ones already exist
    fprintf('Filtering out components for which output already exists...\n') ;
    progress_bar = progress_bar_object(components_to_process_count) ;
    does_output_exist_from_processing_index = false(1, components_to_process_count) ;
    if do_force_computations ,
        progress_bar.update(components_to_process_count) ;
    else
        digits_needed_for_index = floor(log10(max_component_id)) + 1 ;
        tree_name_template = sprintf('auto-cc-%%0%dd', digits_needed_for_index) ;  % e.g. 'tree-%04d'      
        for processing_index = 1 : components_to_process_count ,
            component_id = ...
                component_id_from_processing_index(processing_index) ;
            tree_name = sprintf(tree_name_template, component_id) ;
            tree_mat_file_name = sprintf('%s.mat', tree_name) ;
            tree_mat_file_path = fullfile(output_folder_path, tree_mat_file_name);
            does_output_exist_from_processing_index(processing_index) = logical(exist(tree_mat_file_path, 'file')) ;
            progress_bar.update(processing_index) ;
        end    
    end
    component_id_from_will_process_index = component_id_from_processing_index(~does_output_exist_from_processing_index) ;
    will_process_count = length(component_id_from_will_process_index) ;        
    fprintf('%d components left.\n', will_process_count) ;

    % Figure out how many components are 'big', we'll do those one at a
    % time so as not to run out of memory   
    big_component_threshold = 1e4 ;
    if do_all_computations_serially ,
        do_process_serially_from_will_process_index = true(size(component_id_from_will_process_index)) ;
    else
        component_size_from_will_process_index = size_from_component_id(component_id_from_will_process_index) ;
        do_process_serially_from_will_process_index = (component_size_from_will_process_index>=big_component_threshold) ;
    end
    component_id_from_serial_will_process_index = component_id_from_will_process_index(do_process_serially_from_will_process_index) ;
    component_id_from_parallel_will_process_index = component_id_from_will_process_index(~do_process_serially_from_will_process_index) ;
    %component_size_from_serial_will_process_index = component_size_from_component_id(component_id_from_serial_will_process_index) ;
    %component_size_from_parallel_will_process_index = component_size_from_component_id(component_id_from_parallel_will_process_index) ;
    components_to_process_serially_count = length(component_id_from_serial_will_process_index) ;
    components_to_process_in_parallel_count = length(component_id_from_parallel_will_process_index) ;

    fprintf('Starting the serial for loop, going to process %d components...\n', components_to_process_serially_count) ;
    parfor_progress(components_to_process_serially_count) ;

    % Do the big ones in a regular for loop, since each requires a lot of
    % memory    
    for process_serially_index = 1 : components_to_process_serially_count ,
    %for process_serially_index = 1 : 100 ,
        component_id = component_id_from_serial_will_process_index(process_serially_index) ;        

        % Process this component
        component = component_from_component_id{component_id} ;
        xyzs_for_component = skeleton_xyzs(component,:) ;        
        %G_for_component = G.subgraph(component) ;  % very very very slow!
        A_for_component = A(component, component) ;  

        named_tree = process_single_component_as_function(component_id, ...
                                                          max_component_id, ...
                                                          A_for_component, ...
                                                          xyzs_for_component, ...
                                                          size_threshold, ...
                                                          smoothing_filter_width, ...
                                                          length_threshold, ...
                                                          do_visualize, ...
                                                          sampling_interval) ;

        % If tree too small after pruning, named_tree will be empty
        if ~isempty(named_tree) ,
            % Compute the output file path
            tree_mat_file_name = sprintf('%s.mat', named_tree.name) ;
            tree_mat_file_path = fullfile(output_folder_path, tree_mat_file_name);    

            % Write full tree as a .mat file
            save_named_tree_as_mat(tree_mat_file_path, named_tree) ;
        end

        % Update the progress bar
        parfor_progress() ;
    end
    parfor_progress(0) ;


    % Do the small ones in a parfor loop, since memory is less of an issue
    % for them    
    fprintf('Starting the parallel for loop, will process %d components...\n', components_to_process_in_parallel_count) ;
    use_this_many_cores(maximum_core_count_desired) ;
    parfor_progress(components_to_process_in_parallel_count) ;
    component_from_component_id_as_parpool_constant = parallel.pool.Constant(component_from_component_id) ;
    skeleton_xyzs_as_parpool_constant = parallel.pool.Constant(skeleton_xyzs) ;
    A_as_parpool_constant = parallel.pool.Constant(A) ;
    parfor process_in_parallel_index = 1 : components_to_process_in_parallel_count ,          
        component_id = component_id_from_parallel_will_process_index(process_in_parallel_index) ;
        % Get all the parpool constants
        component_from_component_id_local = component_from_component_id_as_parpool_constant.Value ;
        skeleton_xyzs_local = skeleton_xyzs_as_parpool_constant.Value ;
        A_local = A_as_parpool_constant.Value ;
        % Process this component
        component = component_from_component_id_local{component_id} ;
        xyzs_for_component = skeleton_xyzs_local(component,:) ;
        %G_for_component = G_local.subgraph(component) ;  % slow slow slow
        A_for_component = A_local(component, component) ;  

        named_tree = process_single_component_as_function(component_id, ...
                                                          max_component_id, ...
                                                          A_for_component, ...
                                                          xyzs_for_component, ...
                                                          size_threshold, ...                                                      
                                                          smoothing_filter_width, ...
                                                          length_threshold, ...
                                                          do_visualize, ...
                                                          sampling_interval) ;

        % If tree too small after pruning, named_tree will be empty
        if ~isempty(named_tree) ,
            % Compute the output file path
            tree_mat_file_name = sprintf('%s.mat', named_tree.name) ;
            tree_mat_file_path = fullfile(output_folder_path, tree_mat_file_name);    

            % Write full tree as a .mat file
            save_named_tree_as_mat(tree_mat_file_path, named_tree) ;
        end

        % Update the progress bar
        parfor_progress() ;
    end    
    parfor_progress(0) ;

    toc(runtic) ;
end
