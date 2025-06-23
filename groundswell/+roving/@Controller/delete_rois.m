function delete_rois(self,roi_indices_to_delete)
  
% change the model
self.model.delete_rois(roi_indices_to_delete);

% change the view
self.view.delete_rois(roi_indices_to_delete);

% modify ourself as needed
n_roi=length(self.model.roi);
if n_roi==0
  self.card_birth_roi_next=1;  % reset this
end

% check that all is consistent
n_roi_model=self.model.n_rois;
n_roi_view=length(self.view.border_roi_h);
if n_roi_model~=n_roi_view
  error('model and view out of sync');
end

end
