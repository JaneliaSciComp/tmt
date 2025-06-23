function delete_selected_roi(self)

i=self.view.selected_roi_index;
if ~isempty(i)
  self.delete_rois(i);
end

end
