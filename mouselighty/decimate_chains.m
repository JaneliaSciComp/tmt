function decimated_chains = decimate_chains(chains, xyz, desired_sampling_interval)
    % Decimate chains
    chain_count = length(chains) ;
    decimated_chains = cell(chain_count, 1) ;
    for chain_id = 1 : chain_count ,
        % Get the node ids for this chain
        chain = chains{chain_id} ;               
        decimated_chain = decimate_chain(chain, xyz, desired_sampling_interval) ;
        decimated_chains{chain_id} = decimated_chain ;
    end    
end
