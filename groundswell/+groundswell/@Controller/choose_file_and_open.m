function choose_file_and_open(self)

% throw up the dialog box
[filename,pathname]=...
  uigetfile({'*.tcs' 'Traces file (*.tcs)'},...
            'Open...');
if isnumeric(filename) || isnumeric(pathname)
  % this happens if user hits Cancel
  return;
end

% load the optical data
file_name_full=fullfile(pathname,filename);
self.open(file_name_full);

end
