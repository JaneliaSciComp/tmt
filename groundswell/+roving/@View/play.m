function play(self,direction)

% play the movie
start_frame_index=self.frame_index;
n_frames=self.model.n_frames;
%n_rois=length(self.model.roi);
% tempargh set(self.image_h,'EraseMode','none');
fps=self.model.fs;
% sometimes self.model.fs is nan, b/c the frame rate was not specified.
if ~isfinite(fps)
  fps=20;  % just for playback purposes
end
spf=1/fps;
% if (direction>0)
%   frame_sequence=start_frame_index:n_frames;
% else
%   frame_sequence=start_frame_index:-1:1;
% end
self.stop_button_hit=false;
frame_index=start_frame_index;
%for frame_index=frame_sequence
%tic;
while (1<=frame_index) && (frame_index<=n_frames)
  %dt_this=toc;
  %fs=1/dt_this
  tic;
  self.frame_index=frame_index;
  set(self.image_h,'CData',self.indexed_frame);
  set(self.frame_index_edit_h,'String',num2str(frame_index));
  self.sync_overlay();
  drawnow;  % N.B.: this allows other callbacks to run!
  while (toc < spf)
  end
  if self.stop_button_hit
    break;
  end
  frame_index=frame_index+direction;
end
self.stop_button_hit=false;

end
