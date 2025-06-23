function newly_opened_file(self)
% Called after a new file has been opened in the model.  Updates the view
% appropriately, and initializes the view state as appropriate for a newly
% opened file.

% Update the view's internal state

% determine the colorbar bounds
[data_min,data_max]=self.model.pixel_data_type_min_max();
self.colorbar_min_string=sprintf('%d',data_min);
self.colorbar_max_string=sprintf('%d',data_max);
self.colorbar_min=str2double(self.colorbar_min_string);
self.colorbar_max=str2double(self.colorbar_max_string);
                            
% reset the frame index
self.frame_index=1;

% init roi state
self.selected_roi_index=zeros(0,1);
self.hide_rois=false;
      
% set the mode to elliptic_roi
self.set_mode('elliptic_roi');

% Update the view HG objects to match the model & view state
self.model_changed();

end
