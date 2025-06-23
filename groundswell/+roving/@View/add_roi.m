function add_roi(self,r_border,label_str)

% this_line_h is the line HG object of the new ROI.
% label_this is a string holding the label.

% how many rois currently in the view?
n_rois_old=length(self.border_roi_h);

% calc the center-of-mass for this ROI
com=roving.border_com(r_border);

% make the label HG object for this ROI
this_label_h=...
  text('Parent',self.image_axes_h,...
       'Position',[com(1) com(2) 2],...
       'String',label_str,...
       'HorizontalAlignment','center',...
       'VerticalAlignment','middle',...
       'Color',[0 0 1],...
       'Tag','label_h',...
       'Clipping','on',...         
       'ButtonDownFcn',@(src,event)(self.mouse_button_down_in_image()));

% Make the line GH for the border.
n_vertex=size(r_border,2);
border_h=...
  line('Parent',self.image_axes_h,...
       'Color',[1 0 0],...
       'Tag','border_h',...
       'XData',r_border(1,:),...
       'YData',r_border(2,:),...
       'ZData',repmat(2,[1 n_vertex]),...
       'ButtonDownFcn',@(src,event)(self.mouse_button_down_in_image()));

% commit the changes to the figure variables
self.border_roi_h(end+1)=border_h;
self.label_roi_h(end+1)=this_label_h;

% select the just-created ROI
self.select_roi(n_rois_old+1);

% if this is the first ROI, need to do some stuff
if n_rois_old==0
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
