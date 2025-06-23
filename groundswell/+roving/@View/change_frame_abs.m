function change_frame_abs(self,new_frame_index)

% Change the current frame to the given frame index.

n_frames=self.model.n_frames;
if (new_frame_index>=1) && (new_frame_index<=n_frames)
  self.frame_index=new_frame_index;
  set(self.frame_index_edit_h,'String',sprintf('%d',new_frame_index));
  set(self.image_h,'CData',self.indexed_frame);
  self.sync_overlay();
end

end
