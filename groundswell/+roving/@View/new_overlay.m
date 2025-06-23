function new_overlay(self)

% Updates the view to reflect the overlay currently in the model.

% Read the overlay for the current frame
frame_overlay=self.model.get_frame_overlay(self.frame_index);

% clear the old overlay HG objects
if ~isempty(self.overlay_h)
  delete(self.overlay_h);
end

% draw the new overlay for the current frame
n_things=length(frame_overlay);
self.overlay_h=zeros(n_things,1);
for i=1:n_things
  self.overlay_h(i)=frame_overlay{i}.draw_into_axes(self.image_axes_h);
end

% show the overlay, no matter how things were set before
self.set_show_overlay(true);
set(self.show_overlay_menu_h,'enable','on');

end
