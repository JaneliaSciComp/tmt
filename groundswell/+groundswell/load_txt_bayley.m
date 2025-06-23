function [t,data,trace_names,units]=load_txt_bayley(filename,s)

% s is a scaling factor, in um/pixel
% units in the file are pixels, and we convert before returning

f_s=30;  % Hz
data_fid = fopen(filename,'r');
first_line=fgetl(data_fid);
trace_names_boxed=textscan(first_line,'%s');
trace_names=trace_names_boxed{1};
n_col=length(trace_names);
data_trans=fscanf(data_fid,'%f',[n_col inf]);
fclose(data_fid);
data=data_trans';
i_frame=data(:,1);
data=data(:,2:end);
data=s*data;  % pixels->um
t=(i_frame-1)/f_s;
trace_names=trace_names(2:end);
n_chan=size(data,2);
units=cell(n_chan,1);
for i=1:n_chan
  units{i}='um';
end

end

