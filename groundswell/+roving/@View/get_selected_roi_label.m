function this_label_string=get_selected_roi_label(self)

% Get the selected ROI.
roi_index=self.selected_roi_index;
if isempty(roi_index)
  error(['Internal error: Get selected_roi_label() called when no ROI ' ...
         'selected.']);
end

% get some handles we'll need
%label_h=[self.roi_struct.label_h]';
this_label_h=self.label_roi_h(roi_index);

% get the current label string
this_label_string=get(this_label_h,'String');

end
