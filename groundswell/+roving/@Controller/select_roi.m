function select_roi(self,new_selected_roi_index)

% empty new_selected_roi_index means no change

% get the old roi
old_selected_roi_index=self.selected_roi_index;
if isnan(old_selected_roi_index)
  error('need to stop setting selected roi index to nan');
end

% check for legacy-related errors
if new_selected_roi_index==0
  error('need to stop setting new selected roi index to zero');
end

% if the new selection is empty, do nothing
if isempty(new_selected_roi_index)
  return;
end

% change the selected roi
if ~isempty(old_selected_roi_index)
  % make the old ROI label blue, make its z-coord 1
  set(self.label_roi_h(old_selected_roi_index),'Color',[0 0 1]);
  pos=get(self.label_roi_h(old_selected_roi_index),'Position');
  pos(3)=1;
  set(self.label_roi_h(old_selected_roi_index),'Position',pos);
  % make the old ROI border blue, make its z-coord 1
  set(self.border_roi_h(old_selected_roi_index),'Color',[0 0 1]);
  zdata=get(self.border_roi_h(old_selected_roi_index),'ZData');
  zdata=ones(size(zdata));
  set(self.border_roi_h(old_selected_roi_index),'ZData',zdata);
end  
% make the new ROI label red, make its z-coord 2
set(self.label_roi_h(new_selected_roi_index),'Color',[1 0 0]);
pos=get(self.label_roi_h(new_selected_roi_index),'Position');
pos(3)=2;
set(self.label_roi_h(new_selected_roi_index),'Position',pos);
% make the new ROI border red, make its z-coord 2
set(self.border_roi_h(new_selected_roi_index),'Color',[1 0 0]);
zdata=get(self.border_roi_h(new_selected_roi_index),'ZData');
zdata=repmat(2,size(zdata));
set(self.border_roi_h(new_selected_roi_index),'ZData',zdata);
% these two lines are necessary to prevent the unselected boxes from 
% disappearing.  I don't know why they disappear, but there you go.
set(self.image_h,'Selected','on');
set(self.image_h,'Selected','off');  
% ungray the rename, delete roi menus
set(self.rename_roi_menu_h,'Enable','on');  
set(self.delete_roi_menu_h,'Enable','on');
set(self.copy_menu_h,'Enable','on');
% new ROI selected 
self.selected_roi_index=new_selected_roi_index;

end
