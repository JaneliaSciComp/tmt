function [interpolated_chains, interpolated_xyz_from_node_id, interpolated_root_node_id] = ...
        interpolate_chains(chains, xyz_from_node_id, maximum_spacing, root_node_id)
    % chains a cell array, each element holding an array of node_ids.
    % xyz_from_node_id a n x 3 lookup table for getting the xyz coords of a
    % node_id in chains.
    %
    % Return values are similar.  But note that there is no guaranteed
    % correspondence between input node IDs and output node IDs.

    chain_count = length(chains) ;
    interpolated_chains = cell(chain_count, 1) ;
    interpolated_xyz_from_node_id = zeros(0,3) ;

    if chain_count==0 ,
        interpolated_root_node_id = [] ;
        return
    end
    
    if ~exist('root_node_id', 'var') || isempty(root_node_id) ,
        first_chain = chains{1} ;
        root_node_id = first_chain(1) ;
    end
    
    interpolated_node_count_so_far = 0 ;
    for chain_index = 1 : chain_count ,
        % Get the node ids for this chain
        chain = chains{chain_index} ;
        xyz_from_chain_node_index = xyz_from_node_id(chain,:) ;
        interpolated_xyz_from_new_chain_node_index = interpolate_chain_xyzs(xyz_from_chain_node_index, maximum_spacing) ;
        new_chain_node_count = size(interpolated_xyz_from_new_chain_node_index, 1) ;
        interpolated_chain = interpolated_node_count_so_far + (1:new_chain_node_count) ;                
        interpolated_chains{chain_index} = interpolated_chain ;
        interpolated_xyz_from_node_id = vertcat(interpolated_xyz_from_node_id, interpolated_xyz_from_new_chain_node_index) ;  %#ok<AGROW>
        interpolated_node_count_so_far = interpolated_node_count_so_far + new_chain_node_count ;
        if chain(1)==root_node_id ,
            interpolated_root_node_id = interpolated_chain(1) ;
        elseif chain(end)==root_node_id ,
            interpolated_root_node_id = interpolated_chain(end) ;            
        end
    end    
end
