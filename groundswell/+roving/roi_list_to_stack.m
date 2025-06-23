function [roi_stack,labels]=roi_list_to_stack(roi_list,n_rows,n_cols)

% get length
n_rois=length(roi_list);

% translate the borders into masks
roi_stack=zeros(n_rows,n_cols,n_rois);
template=zeros(n_rows,n_cols);
for k=1:n_rois
  this_border=roi_list(k).border;
  x=this_border(1,:);
  y=this_border(2,:);
  roi_stack(:,:,k)=roipoly(template,x,y);
end

% extract labels
labels={roi_list.label}';

