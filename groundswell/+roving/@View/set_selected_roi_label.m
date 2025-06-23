function set_selected_roi_label(self,new_label_string)

% Get the selected ROI.
roi_index=self.selected_roi_index;
if isempty(roi_index)
  return;
end

% get some handles we'll need
this_label_h=self.label_roi_h(roi_index);

% if new value is not taken or empty, change label
if ~isempty(new_label_string) && ~self.model.label_in_use(new_label_string)
  set(this_label_h,'String',new_label_string);
  self.model.roi(roi_index).label=new_label_string;
  % these lines are necessary to prevent the unselected boxes from 
  % disappearing.  I don't know why they disappear, but there you go.
  set(self.image_h,'Selected','on');
  set(self.image_h,'Selected','off');  
end

end
