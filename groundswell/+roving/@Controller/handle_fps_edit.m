function handle_fps_edit(self)

new_fps_string=get(self.view.FPS_edit_h,'String');
new_fps=str2double(new_fps_string);
if isfinite(new_fps) && (new_fps>0)
  self.model.fs=new_fps;
end
self.view.update_fps();

end
