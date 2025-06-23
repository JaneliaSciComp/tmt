function choose_file_and_export_rois_to_image_file(self)

% throw up the dialog box to get file name
[file_name,dir_name]= ...
  uiputfile({'*.tif' 'TIFF file (*.tif)'}, ...
            'Export ROI mask...');
if isnumeric(file_name) || isnumeric(dir_name)
  % this happens if user hits Cancel
  return;
end
file_name_abs=fullfile(dir_name,file_name);

self.export_rois_to_tiff_file(file_name_abs);
                      
end
