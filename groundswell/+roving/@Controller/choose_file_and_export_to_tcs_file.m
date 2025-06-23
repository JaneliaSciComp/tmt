function choose_file_and_export_to_tcs_file(self)

% throw up the dialog box to get file name
[file_name,dir_name]= ...
  uiputfile({'*.tcs' 'Traces file (*.tcs)'}, ...
            'Export ROI signals...');
if isnumeric(file_name) || isnumeric(dir_name)
  % this happens if user hits Cancel
  return;
end
file_name_abs=fullfile(dir_name,file_name);

self.export_to_tcs_file(file_name_abs);
                      
end
