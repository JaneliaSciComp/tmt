function edges = edges_from_chains(chains)
    chain_count = length(chains) ;
    edges_from_chain_id = cell(chain_count, 1) ;
    for chain_id = 1 : chain_count ,
        chain = chains{chain_id} ;
        to = chain(1:end-1) ;
        from = chain(2:end) ;
        edges_from_chain_id{chain_id} = [from(:) to(:)]' ;  % 2 x edge_count_for_this_chain
    end
    edges = [edges_from_chain_id{:}]' ;  % edge_count x 2, all the edges, across all chains
end
