function [t,data,names,units]=load_txt_plain_old(filename)

%try
data=load(filename);
%catch exception
%  %self.view.unhourglass();
%  errordlg(sprintf('Unable to open file %s: %s',filename_local,exception.message));  
%  return;
%end
[n_t,n_chan]=size(data);
% For plain=old text files, we assume the data is sampled at 1 kHz, for
% lack of a better assumption.
dt=0.001;  % s
t=dt*(0:(n_t-1))';  % s
names=cell(n_chan,1);
for i=1:n_chan
  names{i}=sprintf('x%d',i);
end
units=cell(n_chan,1);
for i=1:n_chan
  units{i}='?';
end

% get rid of leading, trailing spaces in names
names=strtrim(names);

end
