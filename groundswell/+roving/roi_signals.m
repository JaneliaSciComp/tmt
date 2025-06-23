function x=roi_signals(t_o,optical,rois)

% t_o should be a col vector w/ (number of frames) elements
% optical should be a 3d array of shape [n_rows,n_cols,(number of frames)]
% rois should be of dim [n_rois,4] or [n_rows n_cols n_rois]

% analyze each of the rois
if isempty(t_o)||isempty(optical)
  n_rois=0;
  roi_dff=[];
else
  n_rows=size(optical,1);
  n_cols=size(optical,2);
  n_frames=size(optical,3);
  ts=(t_o(n_frames)-t_o(1))/(n_frames-1);
  n_rois=size(rois,3);
  n_ppf=n_rows*n_cols;
  optical=reshape(optical,[n_ppf n_frames]);
  rois=reshape(rois,[n_ppf n_rois]);
  x=zeros(n_frames,n_rois);
  for j=1:n_rois
    this_roi=rois(:,j);
    x(:,j)=mean(double(optical(logical(this_roi),:)),1)';
  end  
end

