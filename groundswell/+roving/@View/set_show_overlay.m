function set_show_overlay(self,show_overlay_new)

if show_overlay_new
  % show them
  set(self.overlay_h,'Visible','on');
  self.show_overlay=true;
  set(self.show_overlay_menu_h,'Label','Hide Overlay');
else
  % hide them
  set(self.overlay_h,'Visible','off');
  self.show_overlay=false;
  set(self.show_overlay_menu_h,'Label','Show Overlay');
end

end
