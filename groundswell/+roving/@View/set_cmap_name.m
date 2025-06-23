function set_cmap_name(self,new_cmap_name)

% need to remember the old cmap_name so that we can
% uncheck that menu item
old_cmap_name=self.cmap_name;

% set the chosen cmap_name
self.cmap_name=new_cmap_name;

% uncheck the old menu item
menu_h=eval(sprintf('self.%s_menu_h',old_cmap_name));
set(menu_h,'Checked','off');

% check the new menu item
menu_h=eval(sprintf('self.%s_menu_h',new_cmap_name));
set(menu_h,'Checked','on');

% set the colormap
if strcmp(new_cmap_name,'red_green') ,
  % feval doesn't work with imported functions?
  cmap=roving.red_green(256);
elseif strcmp(new_cmap_name,'red_blue') ,
  % feval doesn't work with imported functions?
  cmap=roving.red_blue(256);
elseif strcmp(new_cmap_name,'parula') && verLessThan('matlab','8.4') ,
  cmap = jet(256) ;  % no parula colormap in early versions  
else
  cmap=feval(new_cmap_name,256);
end
set(self.figure_h,'colormap',cmap);
