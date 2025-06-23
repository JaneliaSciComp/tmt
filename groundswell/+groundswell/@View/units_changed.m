function units_changed(self)

% Called to notify the view that one or more of the units strings in the
% model have changed.
%
% Causes the units string displayed for each signal to be read from the
% model and re-drawn.

% get instance vars we need
axes_hs=self.axes_hs;
names=self.model.names;
units=self.model.units;

% Update the label of each axes
n_chan=length(axes_hs);
for i=1:n_chan
  % Get a HG reference to the y label for this axes.
  y_label_h=get(axes_hs(i),'ylabel');
  % Contrsuct the new label string. 
  if isempty(units{i})
    label_str=names{i};
  else
    label_str=sprintf('%s (%s)',names{i},units{i});
  end
  % Set the string of the text object to the new label.
  set(y_label_h,'string',label_str);
end

end  % function
