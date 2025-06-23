function result = is_file_an_imagej_jumbo_tif(file_name)
    try
        info = imfinfo(file_name) ;
    catch me %#ok<NASGU>
        % If anything goes wrong, likely not even a TIFF
        result = false ;
        return
    end
    if numel(info)==1 ,
        if isequal(info.Format,'tif') ,
            if isfield(info, 'ImageDescription') ,
                description = info.ImageDescription ;
                if length(description)>=6 && isequal(description(1:6),'ImageJ') ,
                    % OK, this seems promising...
                    % Need to parse the description string, get out the "images" field.
                    every_pair_a_string = strsplit(description, '\n') ;
                    every_pair_a_pair = cellfun(@(pair_as_string)(strsplit(pair_as_string,'=')), every_pair_a_string, 'UniformOutput', false) ;
                    names = cellfun(@name_from_pair, every_pair_a_pair, 'UniformOutput', false) ;
                    is_match = cellfun(@(name)(isequal(name,'images')), names) ;                
                    i_images = find(is_match,1) ;
                    if isempty(i_images) ,
                        result = false ;
                    else
                        images_pair = every_pair_a_pair{i_images} ;
                        if length(images_pair)>=2 ,
                            n_frames_as_string = images_pair{2} ;
                            n_frames = str2double(n_frames_as_string) ;
                            if isfinite(n_frames) && isreal(n_frames) && (n_frames>=0) && round(n_frames)==n_frames ,
                                % n_frames looks like a plausible number of frames
                                % if n_frames is greater than 1, this is an imagej-style multi-page tif
                                if n_frames==1 ,
                                    % Only one frame, so this is just a normal TIFF
                                    result = false ;
                                else
                                    % The number of frames in the comment differs from one, so must be an ImageJ "jumbo" TIFF!
                                    result = true ;
                                end
                            else
                                result = false ;
                            end
                        else
                            result = false ;
                        end
                    end                
                else
                    result = false ;
                end
            else
                result = false ;
            end            
        else
            result = false ;
        end
    else
        % If more than one element in info, looks like it's a normal multi-page TIFF (or something else)
        result = false ;
    end
end


    
function result = name_from_pair(pair)
    if ~isempty(pair) ,
        result = pair{1} ;
    else
        result = '' ;
    end
end
                
