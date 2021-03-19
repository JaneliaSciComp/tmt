function result = chain_length_from_chain(chain, xyz)
    xyz_chain = xyz(chain, :) ;
    dr_chain = diff(xyz_chain) ;
    ds_chain = sqrt(sum(dr_chain.^2, 2)) ;  % length of each edge in chain
    result = sum(ds_chain) ;
end    