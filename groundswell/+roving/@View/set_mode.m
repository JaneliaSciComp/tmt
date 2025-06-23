function set_mode(self,new_mode)

% need to remember the old mode so that we can
% uncheck that menu item
old_mode=self.mode;

% if there's a polygonal ROI draw in progress, cancel it
if strcmp(old_mode,'polygonal_roi') && ~strcmp(new_mode,'polygonal_roi')
  if ~isempty(self.polygonal_roi)
    self.polygonal_roi.clear();
    self.polygonal_roi=[];
  end
end

% untoggle the old mode button
old_button_h=...
  findobj(self.figure_h,'Tag',sprintf('%s_button_h',old_mode));
set(old_button_h,'Value',0);

% check the new menu item
new_button_h=...
  findobj(self.figure_h,'Tag',sprintf('%s_button_h',new_mode));
set(new_button_h,'value',1);

% set the chosen mode
self.mode=new_mode;

end
