function open(self,filename)

% filename is a filename, can be relative or absolute.

% Get the absolute filename
filename_abs=groundswell.absolute_filename(filename);
clear filename

% break up the file name
[~,base_name,ext]=fileparts(filename_abs);
filename_local=[base_name ext];

% might take a while...
self.view.hourglass();

% load the data
try
  [names,t_each,data_each,units]=read_tcs(filename_abs);
catch %#ok
  self.view.unhourglass();
  errordlg(sprintf('Unable to open file %s',filename_local), ...
           'Unable to open file');  
  return;
end

% check that all the time bases are valid (no nan's, etc.)
if ~groundswell.all_time_bases_valid(t_each)
  errordlg('At least one signal has an invalid time base.',...
           'Invalid time base');
  self.view.unhourglass();
  return;
end

% have to upsample data_each onto a common timeline, unless they're
% already like that
if groundswell.all_on_same_time_base(t_each)
  [data,t]=groundswell.common_from_each_trivial(t_each,data_each);
else
  if ismac()
    button=questdlg(['All signals not on same time base.  ' ...
                     'Limit time range and upsample slow signals?'],...
                    'Limit time range and upsample?',...
                    'Cancel','Upsample',...
                    'Upsample');
  else
    button=questdlg(['All signals not on same time base.  ' ...
                     'Limit time range and upsample slow signals?'],...
                    'Limit time range and upsample?',...
                    'Upsample','Cancel',...
                    'Upsample');
  end
  if strcmp(button,'Cancel')
    self.view.unhourglass();
    return;
  end
  [t,data]=...
    groundswell.upsample_to_common(t_each,data_each);
end
clear t_each data_each;

% get rid of leading, trailing spaces in names, units
names=strtrim(names);
units=strtrim(units);

% store all the data-related stuff in a newly-created model
file_native=true;
saved=true;  % saved b/c just opened
self.model=groundswell.Model(t,data,names,units, ...
                             filename_abs,file_native, ...
                             saved);

% set fs_str
fs=(length(t)-1)/(t(end)-t(1));  % Hz
self.fs_str=sprintf('%0.16g',fs);

% make the view reflect the modified model
self.view.completely_new_model(self.model);

% ok, we're done
self.view.unhourglass();

end
