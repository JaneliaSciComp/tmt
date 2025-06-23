function delete_all_rois(self)

n_roi=length(self.model.roi);
i_roi=(1:n_roi)';
self.delete_rois(i_roi);

end
