function mouse_button_down_in_image(self)

% get the current mode
mode=self.mode;
% switch on the current roi mode appropriately
switch(mode)
  case 'rect_roi'
    self.draw_rect_roi('start');
  case 'elliptic_roi'
    self.draw_elliptic_roi('start');
  case 'polygonal_roi'
    self.draw_polygonal_roi('down');
  case 'select'
    roi_index=self.find_roi(gcbo);
    if isempty(roi_index)
      self.unselect_selected_roi();
    else 
      if isempty(self.selected_roi_index) || ...
         roi_index~=self.selected_roi_index
        self.select_roi(roi_index);
      end
      self.move_roi('start',roi_index);
    end
  case 'zoom'
    sel_type=get(self.figure_h,'SelectionType');
    switch sel_type
      case 'extend'
        self.zoom_out();
      case 'alternate'
        self.zoom_out();
      case 'open'
        self.zoom_out();
      otherwise
        self.draw_zoom_rect('start');
    end
  case 'move_all'
    self.move_all('start');
end

end
