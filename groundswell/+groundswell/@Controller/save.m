function save(self,filename_abs)

% Use the given filename, or default to the model filename
if nargin<2
  filename_abs=self.model.filename_abs;
end

% break up the file name
[~,base_name,ext]=fileparts(filename_abs);
filename_local=[base_name ext];

% might take a while...
self.view.hourglass();

% load the data
try
  write_tcs_common_timeline(filename_abs, ...
                            self.model.names, ...
                            self.model.t, ...
                            self.model.data, ...
                            self.model.units);
catch  %#ok
  self.view.unhourglass();
  errordlg(sprintf('Unable to save as file %s',filename_local));
  return;
end

% update the model
self.model.saved_as(filename_abs);

% update the view
self.view.saved();

% ok, we're done
self.view.unhourglass();

end
