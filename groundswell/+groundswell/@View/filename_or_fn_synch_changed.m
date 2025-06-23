function filename_or_fn_synch_changed(self)

% Called when the filename, or the filename-model synchronization, has
% changed.  Causes the figure title to be updated appropiately, etc.

[~,base_name,ext]=fileparts(self.model.filename_abs);
filename_local=[base_name ext];
title_string='Groundswell';
if ~isempty(self.model.filename)
  title_string=[title_string ' - ' filename_local];
  if ~synched_to_file
    title_string=[title_string '*'];
  end
end
set(self.fig_h,'name',title_string);

self.update_enablement_of_controls();

end
