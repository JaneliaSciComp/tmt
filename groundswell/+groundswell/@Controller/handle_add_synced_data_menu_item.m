function handle_add_synced_data_menu_item(self,import_mode_str)

% deal with args
if nargin<2
  import_mode_str='';
end
ft_mode=strcmpi(import_mode_str,'FT');
  % true if optical data was acquired in frame-transfer mode
normal_mode=~ft_mode;

% throw up the dialog box
[filename,pathname,i_filter]=...
  uigetfile({'*.abf' 'Axon binary format file (*.abf)'; ...
             '*.tcs' 'Traces file (*.tcs)'; ...
             '*.wav' 'Microsoft waveform audio file (*.wav)'; ...
             '*.txt' 'Text file (*.txt)'; ...
             '*.txt' 'Text file with labels and time stamps (*.txt)';
             '*.txt' 'Bayley-style text file, 5.0 um/pel (*.txt)'; ...
             '*.txt' 'Bayley-style text file, 2.5 um/pel (*.txt)'; ...
             '*.txt' 'Tracked muscles file (*.txt)'; ...
             '*.*'   'All files (*.*)'},...
            'Load data from file...');
if isnumeric(filename) || isnumeric(pathname)
  % this happens if user hits Cancel
  return;
end

% Translate filter index to a file type string
if i_filter==5
  file_type_str='Text file with labels and time stamps';
elseif i_filter==6
  file_type_str='Bayley-style text, 5.0 um/pel';
elseif i_filter==7
  file_type_str='Bayley-style text, 2.5 um/pel';
elseif i_filter==8
  file_type_str='Tracked muscles text';
else
  file_type_str='';
end

% might take a while...
self.view.hourglass();

% load the data to be synched
full_filename=fullfile(pathname,filename);
[data_new,~,names_new,units_new]= ...
  groundswell.load_traces(full_filename,file_type_str);
if isempty(data_new)
  self.view.unhourglass();
  return;
end

% get the selected signal
i_selected=self.view.i_selected;
exposure=self.model.data(:,i_selected);
exposure_mid=(min(exposure)+max(exposure))/2;
exposure=(exposure>exposure_mid);  % boolean

% determine timeline for the exposures
t_exposure_raw= ...
  groundswell.exposure_times(self.model.t,exposure);

% Sort out the exposure times, given the number of frames and 
% the camera acquisition mode.
n_frame=size(data_new,1);
[t_exposure,success] = ...
  groundswell.rectify_exposure_times(t_exposure_raw,n_frame,normal_mode);
if ~success
  self.view.unhourglass();
  return;
end

% Upsample the ROI data, trim the data data to put everything on a common
% time base.
[t,data]=...
  groundswell.upsample_to_common_4arg(self.model.t,self.model.data, ...
                                      t_exposure,data_new);

% merge names, units
names=vertcat(self.model.names,names_new);
units=vertcat(self.model.units,units_new);

% store all the data-related stuff in a newly-created model
saved=false;
self.model=groundswell.Model(t,data,names,units, ...
                             self.model.filename_abs, ...
                             self.model.file_native, ...
                             saved);

% set fs_str
fs=(length(t)-1)/(t(end)-t(1));  % Hz
self.fs_str=sprintf('%0.16g',fs);

% make the view reflect the modified model
self.view.completely_new_model(self.model);

% ok, we're done
self.view.unhourglass();

end
