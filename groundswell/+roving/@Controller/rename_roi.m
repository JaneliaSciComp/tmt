function rename_roi(self)

% get the current label string
this_label_string=self.view.get_selected_roi_label();

% throw up the dialog box
new_label_string=...
  inputdlg({ 'New ROI name:' },...
           'Rename ROI...',...
           1,...
           { this_label_string },...
           'off');
if isempty(new_label_string) 
  return; 
end

% break out the returned cell array                
new_label_string=new_label_string{1};

% if new value is not taken, change label
self.view.set_selected_roi_label(new_label_string);

end
