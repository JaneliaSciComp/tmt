function [ijks, edges, A] = skel2graph(skeleton_txts_folder_name, whole_brain_shape)

    mydir = dir(fullfile(skeleton_txts_folder_name,'*.txt'));
    % check the format for a non zero file
    mysiz = [mydir.bytes];
    fid = fopen(fullfile(skeleton_txts_folder_name,mydir(find(mysiz>0,1)).name));
    tline = fgetl(fid);
    fclose(fid);
    tlines = strsplit(tline,' ');
    numcloumns = size(tlines,2); % first 2 are indicies, rest are weights
    format = ['%f %f', sprintf('%s',repmat(' %f',ones(1,numcloumns-2)))];

    fclose all;
    clear pairs edges
    pairs = cell(1,length(mydir));
    %%
    use_this_fraction_of_cores(1) ;
    %%
    parfor idx = 1:length(mydir)
        if mysiz(idx)==0 %| mysiz>20e6
            continue
        end
        % read text file line by line
        fid = fopen(fullfile(skeleton_txts_folder_name,mydir(idx).name));
        tmp = textscan(fid,format);
        fclose(fid);
        pairs{idx} = cat(2,tmp{:})';
    end
    edges = [pairs{:}]';clear pairs;

%     %%
%     %clc
%     clear subs
%     [keepthese,ia,ic] = unique(edges(:,[1 2]));
%     [ijks(:,1),ijks(:,2),ijks(:,3)] = ind2sub(whole_brain_shape([1 2 3]),keepthese);
%     edges_ = reshape(ic,[],2);
%     weights_ = edges(ia,3:end);
%     if isempty(edges_);return;end
%     if isempty(weights_);weights_ = ones(size(edges_,1),1);end
% 
%     selfinds = find((edges_(:,1)==edges_(:,2)));
%     if ~isempty(selfinds);edges_(selfinds,:)=[];end
%     A = sparse(edges_(:,1),edges_(:,2),1,max(edges_(:)),max(edges_(:)));
%     A = max(A',A);
    
    [A, ijks] = skel2graph_core(edges, whole_brain_shape) ;
end
