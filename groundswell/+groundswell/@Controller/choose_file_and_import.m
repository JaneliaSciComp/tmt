function choose_file_and_import(self)

% throw up the dialog box
[filename,pathname,i_filter]=...
  uigetfile({'*.abf' 'Axon binary format file (*.abf)';...
             '*.wav' 'Microsoft waveform audio file (*.wav)';
             '*.txt' 'Text file (*.txt)';
             '*.txt' 'Text file with labels and time stamps (*.txt)';
             '*.txt' 'Bayley-style text file, 5.0 um/pel (*.txt)';
             '*.txt' 'Bayley-style text file, 2.5 um/pel (*.txt)';
             '*.*'   'All files (*.*)'},...
            'Load data from file...');
if isnumeric(filename) || isnumeric(pathname)
  % this happens if user hits Cancel
  return;
end

% Translate filter index to a file type string
if i_filter==4
  file_type_str='Text file with labels and time stamps';    
elseif i_filter==5
  file_type_str='Bayley-style text, 5.0 um/pel';
elseif i_filter==6
  file_type_str='Bayley-style text, 2.5 um/pel';
else
  file_type_str='';
end

% load the optical data
file_name_full=fullfile(pathname,filename);
self.import(file_name_full,file_type_str);

end
