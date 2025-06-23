function saved=save_as(self)

% throw up the dialog box
[filename,pathname]=...
  uiputfile({'*.tcs' 'Traces file (*.tcs)'},...
            'Save to file...');
if isnumeric(filename) || isnumeric(pathname)
  % this happens if user hits Cancel
  saved=false;
  return;
end

% save the file
filename_abs=fullfile(pathname,filename);
self.save(filename_abs);
saved=true;

end
