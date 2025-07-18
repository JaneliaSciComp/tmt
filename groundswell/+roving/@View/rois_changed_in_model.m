function rois_changed_in_model(self)

% Updates the roi border and roi labels (meaning the HG objects) to 
% be consistent with the ROIs in the model.

% Get the labels and borders from the model.
labels={self.model.roi.label};
borders={self.model.roi.border};

% clear the old roi borders & labels
if self.border_roi_h  % if nonempty
  delete(self.border_roi_h);
  delete(self.label_roi_h);
end

% generate graphics objects for the new ROIs
n_rois=length(labels);
label_h=zeros(n_rois,1);
border_h=zeros(n_rois,1);
for j=1:n_rois
  border_this=borders{j};
  com=roving.border_com(border_this);
  label_h(j)=...
    text('Parent',self.image_axes_h,...
         'Position',[com(1) com(2) 1],...
         'String',labels{j},...
         'HorizontalAlignment','center',...
         'VerticalAlignment','middle',...
         'Color',[0 0 1],...
         'Tag','label_h',...
         'Clipping','on',...
         'ButtonDownFcn',@(~,~)(self.mouse_button_down_in_image()) );
  border_h(j)=...
    line('Parent',self.image_axes_h,...
         'Color',[0 0 1],...
         'Tag','border_h',...
         'XData',border_this(1,:),...
         'YData',border_this(2,:),...
         'ZData',ones([1 size(border_this,2)]),...
         'ButtonDownFcn',@(~,~)(self.mouse_button_down_in_image()) );
end
   
% write the new ROI into the figure state
self.border_roi_h=border_h;
self.label_roi_h=label_h;

end
