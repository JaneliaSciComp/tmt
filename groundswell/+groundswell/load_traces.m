function [data,t,names,units]=load_traces(filename,file_type_str)

% file_type_str is an optional argument containing additional
% info about how to parse the file, beyond that provided by the
% file name extension.  Currently handled values include
% 'Bayley-style text, 2.5 um/pel', 'Bayley-style text, 5.0 um/pel',
% and 'Tracked muscles text'

% process args
if nargin<2 || isempty(file_type_str)
  file_type_str='';
end

% parse the filename
[~,base_name,ext]=fileparts(filename);
filename_local=[base_name ext];

% fall-back return values
data=zeros(0,0);
t=zeros(0,1);
names=cell(0,1);
units=cell(0,1);

% load the data
if strcmp(ext,'.abf')
  try
    [t,data,names,units]=load_abf(filename);
  catch exception
    %self.view.unhourglass();
    errordlg(sprintf('Unable to open file %s: %s',filename_local,exception.message));  
    return;
  end
elseif strcmp(ext,'.tcs')
  try
    [names,t_each,data_each,units]=read_tcs(filename);
  catch exception
    %self.view.unhourglass();
    errordlg(sprintf('Unable to open file %s: %s',filename_local,exception.message));  
    return;
  end
  % have to upsample data_each onto a common timeline, unless they're
  % already like that
  if ~groundswell.all_on_same_time_base(t_each)
    errordlg('All signals not on same time base.');
    return;
  end
  [data,t]=groundswell.common_from_each_trivial(t_each,data_each);
  clear t_each data_each;
elseif strcmp(ext,'.wav')
  try
    [data,fs]=wavread(filename);
  catch exception
    %self.view.unhourglass();
    errordlg(sprintf('Unable to open file %s: %s',filename_local,exception.message));  
    return;
  end
  dt=(1/fs);
  [n_t,n_chan]=size(data);
  t=dt*(0:(n_t-1))';  % s
  names=cell(n_chan,1);
  for i=1:n_chan
    names{i}=sprintf('x%d',i);
  end
  units=cell(n_chan,1);
  for i=1:n_chan
    units{i}='V';
      % it's surprisingly hard to find out how to convert, say, a 16-bit
      % audio sample (as on a CD) to a line-level voltage.  But I think
      % this is correct.  I.e. -2^15 = -32768 => -1 V
  end
elseif strcmp(ext,'.txt')
  try
    if strcmp(file_type_str,'Text file with labels and time stamps')
      [t,data,names,units]= ...
        groundswell.load_txt_with_labels_and_time_stamps(filename);
    elseif strcmp(file_type_str,'Bayley-style text, 2.5 um/pel')
      [t,data,names,units]= ...
        groundswell.load_txt_bayley(filename,2.5);
    elseif strcmp(file_type_str,'Bayley-style text, 5.0 um/pel')
      [t,data,names,units]= ...
        groundswell.load_txt_bayley(filename,5.0);
    elseif strcmp(file_type_str,'Tracked muscles text')
      [t,data,names,units]= ...
        groundswell.load_txt_tracked_muscles(filename);
    else
      [t,data,names,units]= ...
        groundswell.load_txt_plain_old(filename);
    end
  catch exception 
    errordlg(sprintf('Unable to open file %s: %s',filename_local,exception.message));  
    return;
  end
else
  errordlg('Don''t know how to open a file with that extension');
  return;
end

% get rid of leading, trailing spaces in names, units
names=strtrim(names);
units=strtrim(units);

end
