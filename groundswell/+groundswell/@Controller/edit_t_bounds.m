function edit_t_bounds(self)

% get the current tl_view
tl_view=self.view.tl_view;  % always in s

% convert time limits in s to current time units
xl_view=self.view.x_from_t(tl_view);

% get the string corresponding to current time units
str_units=self.view.time_units_string();

% get strings that say the current time limits, in the current
% units
x_min_string=sprintf('%0.6f',xl_view(1));
x_max_string=sprintf('%0.6f',xl_view(2));

% throw up the dialog box
bounds=inputdlg({ sprintf('Time minimum (%s):',str_units) , ...
                  sprintf('Time maximum (%s):',str_units) },...
                'Set bounds...',...
                1,...
                { x_min_string , x_max_string },...
                'off');
if ~isempty(bounds) 
  % break out the returned cell array                
  x_max_string=bounds{2};
  x_min_string=bounds{1};
  % convert all these strings to real numbers
  x_min=str2double(x_min_string);
  x_max=str2double(x_max_string);
  % convert to time in seconds
  t_min=self.view.t_from_x(x_min);
  t_max=self.view.t_from_x(x_max);
  % if new values are kosher, change plot limits
  if ( ~isempty(t_min) && ~isempty(t_max) && ...
       isfinite(t_min) && isfinite(t_max) && ...
       (t_max>t_min) )
     self.set_tl_view([t_min t_max]);
  end
end
