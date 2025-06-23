function all_new_rois(self)

% Updates the view to reflect the ROIs currently in the model.

% Update the labels and border HG objects
self.rois_changed_in_model();

% Don't want any ROIs selected at this point.
self.selected_roi_index=zeros(0,1);

% no ROI is selected, so disable some menus
set(self.delete_roi_menu_h,'Enable','off');
set(self.rename_roi_menu_h,'Enable','off');
set(self.cut_menu_h,'Enable','off');
set(self.copy_menu_h,'Enable','off');

% modify ancillary crap
n_rois=length(self.model.roi);
if n_rois>0
  set(self.delete_all_rois_menu_h,'Enable','on');
  set(self.save_rois_to_file_menu_h,'Enable','on');
  set(self.hide_rois_menu_h,'Enable','on');
  set(self.select_button_h,'Enable','on');
  set(self.move_all_button_h,'Enable','on');
  set(self.export_to_tcs_menu_h,'Enable','on');
  set(self.export_to_mask_menu_h,'Enable','on');    
  % Object invariants are now satisfied, but we un-hide the ROIs
  % as a courtesy at this point.
  self.set_hide_rois(false);  
end  

end
