function [t,data,trace_names,units]=load_txt_with_labels_and_time_stamps(filename)

data_fid = fopen(filename,'r');
first_line=fgetl(data_fid);
trace_names_boxed=textscan(first_line,'%s');
trace_names=trace_names_boxed{1};
n_col=length(trace_names);
data_trans=fscanf(data_fid,'%f',[n_col inf]);
fclose(data_fid);
data=data_trans';
t=data(:,1);  % should be in seconds
data=data(:,2:end);
trace_names=trace_names(2:end);
n_chan=size(data,2);
units=cell(n_chan,1);
for i=1:n_chan
  units{i}='?';
end

end
