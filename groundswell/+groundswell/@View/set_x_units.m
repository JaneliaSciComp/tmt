function set_x_units(self,new_x_units)

% get the figure handle
fig_h=self.fig_h;

% get the current units
old_x_units=self.x_units;

% set the instance var
self.x_units=new_x_units;

% uncheck the old menu item
menu_h=findobj(fig_h,'Tag',sprintf('%s_menu_h',old_x_units));
set(menu_h,'Checked','off');

% check the new menu item
menu_h=findobj(fig_h,'Tag',sprintf('%s_menu_h',new_x_units));
set(menu_h,'Checked','on');

% change the x-axis label, if there is one
axes_hs=self.axes_hs;
if ~isempty(axes_hs)
  xlabel(axes_hs(end),get(menu_h,'label'),'tag','x_axis_label','FontSize',10);
end
