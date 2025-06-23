function change_frame_rel(self,di)

% Change the current frame by di.

frame_index_new=self.frame_index+di;
self.change_frame_abs(frame_index_new);

end
