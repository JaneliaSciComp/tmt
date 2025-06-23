function sync_overlay(self)

% Updates the view to reflect the overlay currently in the model.

if isempty(self.model.overlay_file) || ~self.show_overlay
  % clear current stuff
  if ~isempty(self.overlay_h)
    delete(self.overlay_h);
  end
else
  % Read the overlay for the current frame
  frame_overlay=self.model.get_frame_overlay(self.frame_index);

  % clear current stuff
  if ~isempty(self.overlay_h)
    delete(self.overlay_h);
  end

  % draw the new overlay for the current frame
  n_things=length(frame_overlay);
  self.overlay_h=zeros(n_things,1);
  for i=1:n_things
    self.overlay_h(i)=frame_overlay{i}.draw_into_axes(self.image_axes_h);
  end
end

end
