function choose_roi_file_and_load(self)

% throw up the dialog box
[filename,pathname]= ...
  uigetfile({'*.rpb' 'ROI polygonal boundary file (*.rpb)'}, ...
            'Load ROIs from File...');
if isnumeric(filename) || isnumeric(pathname)
  % this happens if user hits Cancel
  return;
end

% call the appropriate loader
filename_abs=fullfile(pathname,filename);
self.load_rois_from_rpb(filename_abs);
