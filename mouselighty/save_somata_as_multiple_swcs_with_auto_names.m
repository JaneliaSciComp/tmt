function save_somata_as_multiple_swcs_with_auto_names(output_folder_name, name_prefix, somata_xyzs, color)
    % Determine color if not given
    if ~exist('color', 'var') || isempty(color) , 
        hue = rand(1) ;
        saturation = 1 ;
        value = 0.9 ;  % Want to maintain some contrast against a white background
        color = hsv2rgb([hue saturation value]) ;
    end
    
    % Figure out field sizes
    soma_count = size(somata_xyzs, 1) ;
    digits_needed_for_index = floor(log10(soma_count)) + 1 ; 
    max_soma_xyz = max(somata_xyzs, [], 1) ;
    digits_needed_for_z = floor(log10(max_soma_xyz(3))) + 1 ;  
    digits_needed_for_x = floor(log10(max_soma_xyz(1))) + 1 ;  
    name_template = sprintf('%s-z%%0%dd-x%%0%dd-id%%0%dd', name_prefix, digits_needed_for_z, digits_needed_for_x, digits_needed_for_index) ;
    
    % Make sure the output folder exists
    if ~exist(output_folder_name, 'file') ,
        mkdir(output_folder_name) ;
    end    

    % Output the files
    for soma_index = 1 : soma_count ,
        soma_xyz = somata_xyzs(soma_index, :) ;
        name = sprintf(name_template, round(soma_xyz(3)), round(soma_xyz(1)), soma_index) ;
        file_name = [name '.swc'] ;
        file_path = fullfile(output_folder_name, file_name) ;
        save_somata_as_single_swc(file_path, soma_xyz, name, color) ;
    end
end
