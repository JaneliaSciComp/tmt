function roi_index=find_roi(self,h)

% Given a graphics handle h, which is the handle of either a ROI
% border line or a ROI label, returns the index of the ROI in question.
% if h doesn't represent an roi decoration, empty is returned

% get handles we'll need
border_h=self.border_roi_h;
label_h=self.label_roi_h;
n_rois=length(label_h);

% return the ROI index
if n_rois>0
  new_selected_roi=find(border_h==h|label_h==h);
  if isempty(new_selected_roi)
    roi_index=[];
  else
    roi_index=new_selected_roi(1);
  end
else
  roi_index=[];
end
