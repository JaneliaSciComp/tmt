function choose_overlay_file_and_load(self)

% throw up the dialog box
[filename,pathname]= ...
  uigetfile({'*.ovl' 'Overlay file (*.ovl)'}, ...
            'Load Overlay from File...');
if isnumeric(filename) || isnumeric(pathname)
  % this happens if user hits Cancel
  return;
end

% call the appropriate loader
self.load_overlay_from_ovl(filename,pathname);
