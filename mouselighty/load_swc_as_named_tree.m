function tree = load_swc_as_named_tree(swc_file_name)
    %LOADSWC reads a JW formatted swc file and return color/header and data
    %fields
    %
    % [OUTPUTARGS] = LOADSWC(INPUTARGS) Explain usage here
    %
    % Examples:
    %     [swcData,offset,color, header] = loadSWC(swcfile);
    %     swcData(:,3:5) = swcData(:,3:5) + ones(size(swcData,1),1)*offset;
    %     swcData(:,3:5) = swcData(:,3:5)*scale;
    %
    % Provide sample usage code here
    %
    % See also: List related files here

    % $Author: base $	$Date: 2015/08/14 12:09:52 $	$Revision: 0.1 $
    % Copyright: HHMI 2015

    %% parse a swc file
    offset = [0 0 0] ;
    header = cell(1);

    fid = fopen(swc_file_name);
    if fid < 0 ,
        error('Unable to open .swc file %s for reading', swc_file_name) ;
    end
    this_line = fgets(fid);
    skipline = 0;
    header_line_count = 1;
    centerpoint_count = 0 ;
    was_name_specified = false ;
    was_color_specified = false ;
    while ischar(this_line)
        % assumes that all header info is at the top of the swc file
        if strcmp(this_line(1), '#')
            skipline = skipline + 1;
            header{header_line_count} = this_line;
            header_line_count = header_line_count+1;
        else
            centerpoint_count = centerpoint_count + 1 ;
            this_line = fgets(fid);            
            continue;
            %break
        end
        % if get here, tline contains a header line
        tokens = strsplit(deblank(this_line)) ;
        token_count = length(tokens) ;
        if token_count>=2 && isequal(tokens{2}, 'OFFSET') ,
            tokens = strsplit(deblank(this_line)) ;
            tokens_as_double = cellfun(@str2double, tokens) ;
            numeric_tokens = tokens_as_double(~isnan(tokens_as_double)) ;
            if isequal(size(numeric_tokens), [1 3]) ,
                offset = numeric_tokens ;
            else
                error('Unable to parse OFFSET header line: "%s"', this_line) ;
            end
        elseif token_count>=2 && isequal(tokens{2}, 'COLOR') ,
            indices_of_tag = strfind(this_line, 'COLOR') ;
            start_of_tag_index = indices_of_tag(1) ;
            just_after_tag_index = start_of_tag_index + length('COLOR') ;
            rest_of_line = this_line(just_after_tag_index:end) ;
            color = cellfun(@str2double,strsplit(deblank(rest_of_line),','));
            was_color_specified = true ;
        elseif token_count>=2 && isequal(tokens{2}, 'NAME') ,
            indices_of_tag = strfind(this_line, 'NAME') ;
            start_of_tag_index = indices_of_tag(1) ;
            just_after_tag_index = start_of_tag_index + length('NAME') ;
            rest_of_line = this_line(just_after_tag_index:end) ;
            name = deblank(rest_of_line) ;
            was_name_specified = ~isempty(name) ;
        end
        this_line = fgets(fid);
    end
    fclose(fid);

    fid = fopen(swc_file_name);
    for i=1:skipline
        this_line = fgets(fid);  %#ok<NASGU>
    end
    swc_data_from_node_index = zeros(centerpoint_count,7) ;
    this_line = fgets(fid);
    tl = 1;
    while ischar(this_line)
        swc_data_from_node_index(tl,:) = str2num(this_line);  %#ok<ST2NM>
        tl = tl+1;
        this_line = fgets(fid);
    end
    fclose(fid);
    
    % Re-map the parent array so that  terms of the node index, not the
    % node ids given in the first swc column
    node_id_from_node_index = swc_data_from_node_index(:,1) ;
    node_index_from_node_id = invert_map_array(node_id_from_node_index) ;
    parent_node_id_from_node_index = swc_data_from_node_index(:,7) ;
    root_node_index = find(parent_node_id_from_node_index==-1) ;
    parent_node_id_from_node_index(root_node_index) = 1 ;  % so next line works
    parent_node_index_from_node_index = node_index_from_node_id(parent_node_id_from_node_index) ;    
    parent_node_index_from_node_index(root_node_index) = -1 ;  % put root where it belongs
    
    % Break columns out of swc_data
    raw_centerpoints = swc_data_from_node_index(:,3:5) ;
    xyz_from_node_index = bsxfun(@plus, raw_centerpoints, offset) ;    
    r_from_node_index = swc_data_from_node_index(:,6) ;
    tag_code_from_node_index = swc_data_from_node_index(:,2) ;
    
    if ~was_color_specified, 
        color = [ 1 0 1 ] ;  % magenta.  what the hell...
    end
    if ~was_name_specified, 
        random_number = floor(1e6 * rand(1)) ;
        name = sprintf('unnamed-%06d', random_number) ;
    end    
    
    tree = struct('name', name, ...
                  'color', color, ...
                  'xyz', xyz_from_node_index, ...
                  'r', r_from_node_index, ...
                  'parent', parent_node_index_from_node_index, ...
                  'tag_code', tag_code_from_node_index) ;
end
