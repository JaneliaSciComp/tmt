function import(self,filename,file_type_str)

% filename is a filename, can be relative or absolute
% file_type_str is an optional arg providing additional file type info.

% deal with args
if nargin<3 || isempty(file_type_str)
  file_type_str='';
end

% Get the absolute filename
filename_abs=groundswell.absolute_filename(filename);
clear filename

% might take a while...
self.view.hourglass();

% load the data
[data,t,names,units]=groundswell.load_traces(filename_abs,file_type_str);

% if we actually got data back, set the model to it
if ~isempty(data)
  % store all the data-related stuff in a newly-created model
  file_native=false;  % because it's an import
  saved=true;  % b/c just opened
  self.model=groundswell.Model(t,data,names,units, ...
                               filename_abs,file_native, ...
                               saved);

  % Set the string the represents the sampling rate
  fs=(length(t)-1)/(t(end)-t(1));  % Hz
  self.fs_str=sprintf('%0.16g',fs);

  % make the view reflect the modified model
  self.view.completely_new_model(self.model);
end

% ok, we're done
self.view.unhourglass();

end
