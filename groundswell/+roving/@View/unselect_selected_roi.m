function unselect_selected_roi(self)

% get the old roi
old_selected_roi_index=self.selected_roi_index;

if isnan(old_selected_roi_index)
  % nothing to do
else
  % make the old ROI label blue, make it's height 1
  label_h=self.label_roi_h;
  set(label_h(old_selected_roi_index),'Color',[0 0 1]);
  pos=get(label_h(old_selected_roi_index),'Position');
  pos(3)=1;
  set(label_h(old_selected_roi_index),'Position',pos);
  % make the old ROI border blue, make it's height 1
  border_h=self.border_roi_h;
  set(border_h(old_selected_roi_index),'Color',[0 0 1]);
  zdata=get(border_h(old_selected_roi_index),'ZData');
  zdata=ones(size(zdata));
  set(border_h(old_selected_roi_index),'ZData',zdata);
  % these two lines are necessary to prevent the unselected boxes from 
  % disappearing.  I don't know why they disappear, but there you go.
  set(self.image_h,'Selected','on');
  set(self.image_h,'Selected','off');  
  % gray the rename, delete roi menus
  set(self.rename_roi_menu_h,'Enable','off');
  set(self.delete_roi_menu_h,'Enable','off');
  set(self.cut_menu_h,'Enable','off');
  set(self.copy_menu_h,'Enable','off');
  % no ROI selected anymore
  self.selected_roi_index=zeros(0,1);
  % disable the edit mode
  %set(self.edit_roi_button_h,'Enable','off');
end

end
