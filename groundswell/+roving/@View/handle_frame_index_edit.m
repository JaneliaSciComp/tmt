function handle_frame_index_edit(self)

new_frame_index_string=get(self.frame_index_edit_h,'String');
new_frame_index=str2double(new_frame_index_string);
n_frames=self.model.n_frames;
if (new_frame_index>=1) && (new_frame_index<=n_frames)
  self.change_frame_abs(new_frame_index);
else
  set(self.frame_index_edit_h, ...
      'String',sprintf('%d',self.frame_index));
end

end
