function result = decimate_chain(chain, xyz, desired_sampling_interval)
    % Get length of chain
    xyz_chain = xyz(chain, :) ;
    dxyz_chain = diff(xyz_chain) ;        
    ds = sqrt( sum(dxyz_chain.^2, 2) ) ;  % length of each edge in the chain of nodes 
    s = [ 0 ; cumsum(ds) ] ;
    % Determine which nodes to keep, taking care that we always keep
    % the chain ends
    chain_length_in_um = s(end) ;
    if chain_length_in_um > desired_sampling_interval ,
        do_keep = logical([1;diff(floor(s/desired_sampling_interval))]) ;
        do_keep(end) = true ;
        result = chain(do_keep) ;
        % Code below leads to repeated node_ids!
%         desired_s = (0:desired_sampling_interval:chain_length_in_um-desired_sampling_interval)' ;
%         distance_matrix = pdist2(desired_s, s(:)) ;
%         [~,idx] = min(distance_matrix, [], 2) ;
%         result = [chain(idx) chain(end)] ;
    else
        result = [chain(1) chain(end)] ;
    end
end
