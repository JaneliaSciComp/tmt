function load_rois_from_rpb(self,full_filename)

%
% load in the ROI data from the file, w/ error checking
%

try
  self.model.load_rois_from_rpb(full_filename);
catch  %#ok
  [~,basename,ext]=fileparts(full_filename);
  filename=[basename ext];
  uiwait(errordlg(sprintf('Unable to open file %s',filename),...
                  'File Error', ...
                  'modal'));
  return
end

% notify the view
self.view.all_new_rois();

% modify self as needed
n_rois=self.model.n_rois;
self.card_birth_roi_next=n_rois+1;

end
