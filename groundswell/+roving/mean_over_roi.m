function x_roi=mean_over_roi(vid,roi_stack)

% vid should be a 3d array of shape [n_rows,n_cols,(number of frames)].
% vid can be uint8, uint16, or double.
% roi_stack should be of dim [n_rois,4] or [n_rows n_cols n_rois]

% analyze each of the rois
%[n_row,n_col,n_frame]=size(vid);
n_frame=size(vid,3);
n_roi=size(roi_stack,3);
n_pel=reshape(sum(sum(roi_stack,2),1),[n_roi 1]);  % pels in each roi
%n_ppf=n_row*n_col;  % pixels per frame
x_roi=zeros(n_frame,n_roi);

% % this loop is made fast (enough) by the Matlab JIT
% for l=1:n_roi
%   for k=1:n_frame
%     s=0;
%     n=0;
%     for i=1:n_row
%       for j=1:n_col
%         if roi_stack(i,j,l)
%           s=s+vid(i,j,k);
%           n=n+1;
%         end
%       end
%     end
%     x_roi(k,l)=s/n;
%   end
% end
 
% is this faster?  yes.  just-in-time, my ass.
for l=1:n_roi
  roi_mask=roi_stack(:,:,l);
  for k=1:n_frame
    s=sum(sum(roi_mask.*double(vid(:,:,k))));
    x_roi(k,l)=s/n_pel(l);
  end
end

end
