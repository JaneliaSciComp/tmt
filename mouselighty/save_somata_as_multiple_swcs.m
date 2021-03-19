function save_somata_as_multiple_swcs(output_folder_name, file_names_or_file_name_template, somata_xyzs, names_or_name_template, color)

    if iscell(file_names_or_file_name_template) ,
        file_names = file_names_or_file_name_template ;
        do_have_file_names = true ;
        do_have_file_name_template = false ;
    else
        file_name_template = file_names_or_file_name_template ;
        do_have_file_names = false ;
        do_have_file_name_template = true ;
    end
    
    if iscell(names_or_name_template) ,
        names = names_or_name_template ;
        do_have_names = true ;
        do_have_name_template = false ;
    else
        name_template = names_or_name_template ;
        do_have_names = false ;
        do_have_name_template = true ;
    end
    
    if ~exist('color', 'var') || isempty(color) , 
        hue = rand(1) ;
        saturation = 1 ;
        value = 0.9 ;  % Want to maintain some contrast against a white background
        color = hsv2rgb([hue saturation value]) ;
    end
    
    % Make sure the output folder exists
    if ~exist(output_folder_name, 'file') ,
        mkdir(output_folder_name) ;
    end
    
    soma_count = size(somata_xyzs, 1) ;
    for soma_index = 1 : soma_count ,
        soma_xyz = somata_xyzs(soma_index, :) ;
        if do_have_file_names ,
            file_name = file_names{soma_index} ;
        elseif do_have_file_name_template ,
            file_name = sprintf(file_name_template, soma_index) ;
        else
            error('No file names or file name template!') ;
        end        
        file_path = fullfile(output_folder_name, file_name) ;
        if do_have_names ,
            name = names{soma_index} ;
        elseif do_have_name_template ,
            name = sprintf(name_template, soma_index) ;
        else
            error('No names or name template!') ;
        end
        save_somata_as_single_swc(file_path, soma_xyz, name, color) ;
    end
end
