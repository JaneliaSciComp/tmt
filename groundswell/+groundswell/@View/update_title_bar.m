function update_title_bar(self)

% Updates the title bar to match the current model state.

% Build the title string
title_string='Groundswell';
if ~isempty(self.model)
  [~,base_name,ext]=fileparts(self.model.filename_abs);
  filename_local=[base_name ext];
  title_string=[title_string ' - ' filename_local];
  if ~self.model.saved
    title_string=[title_string '*'];
  end
end

% Set the figure "name" to title_string
set(self.fig_h,'name',title_string);

end
