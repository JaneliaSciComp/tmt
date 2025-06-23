function update_fps(self)

if isfinite(self.model.fs)
  FPS_edit_string=sprintf('%6.2f',self.model.fs);
else
  FPS_edit_string='   ?  ';
end  
set(self.FPS_edit_h,'String',FPS_edit_string);

end
