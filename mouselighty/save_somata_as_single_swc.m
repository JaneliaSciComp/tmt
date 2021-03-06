function save_somata_as_single_swc(file_name, somata_xyzs, name, color)
    
    if ~exist('color', 'var') || isempty(color) , 
        hue = rand(1) ;
        saturation = 1 ;
        value = 0.9 ;  % Want to maintain some contrast against a white background
        color = hsv2rgb([hue saturation value]) ;
    end
    
    soma_count = size(somata_xyzs, 1) ;
    offset = mean(somata_xyzs,1) ;
    somata_xyzs_centered = bsxfun(@minus, somata_xyzs, offset) ;
    
    node_ids = (1:soma_count)' ;    
    structure_identifiers = ones(soma_count, 1) ;
    radii = ones(soma_count, 1) ;  % made-up BS
    parents = -ones(soma_count, 1) ;  % each node is a root
    centered_swc_data = [node_ids structure_identifiers somata_xyzs_centered radii parents] ;
    
    fid = fopen(file_name,'wt') ;
    fprintf(fid, '# Generated by save_somata_as_single_swc.m\n') ;
    fprintf(fid, '# OFFSET %24.17g %24.17g %24.17g\n', offset) ;
    fprintf(fid, '# COLOR %0.6f %0.6f %0.6f\n', color) ;
    fprintf(fid, '# NAME %s\n', name) ;
    fprintf(fid,'%d %d %24.17g %24.17g %24.17g %d %d\n',centered_swc_data') ;
    fclose(fid) ;
end
