function count_ttl_edges(self)

% get stuff we'll need
selected=self.view.get_selected_axes();
%t=self.model.t;
data=self.model.data;
%N=size(data,1);
names=self.model.names;
units=self.model.units;

% get the selected signal
n_signals=sum(selected);
if n_signals==0
  return;
elseif n_signals>1
  errordlg('Can only count TTL edges on one signal at a time.',...
           'Error');
  return;
end
data=data(:,selected);
name=names{selected};
units=units{selected};

% may take a while
self.view.hourglass();

% Count the number of rising, falling edges
data_max=max(data);
data_min=min(data);
thresh=(data_min+data_max)/2;
above_thresh=(data>=thresh);
rising_edge  =  above_thresh(2:end) & ~above_thresh(1:end-1);
falling_edge = ~above_thresh(2:end) &  above_thresh(1:end-1);
n_rising=sum(rising_edge);
n_falling=sum(falling_edge);

% Format the output string
output_str=sprintf(['Rising edges: %d\n' ...
                    'Falling edges: %d\n' ...
                    'Threshold used: %0.3g %s'], ...
                   n_rising,n_falling,thresh,units);
                 
% set pointer back
self.view.unhourglass()

% Display the message dialog box
msgbox(output_str,sprintf('TTL Edges of signal %s',name));

end
