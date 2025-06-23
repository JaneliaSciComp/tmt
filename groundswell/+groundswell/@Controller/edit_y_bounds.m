function edit_y_bounds(gsmc)

% get stuff we'll need
axes_hs=gsmc.view.axes_hs;
i_selected=gsmc.view.i_selected;

% check number of selected axes
n_selected=length(i_selected);
if n_selected<1
  % this shouldn't ever happen
  return;
end

% get the limits of the pivot
i_pivot=i_selected(end);
yl=get(axes_hs(i_pivot),'ylim');

% get strings that say the current time limits, in the current
% units
y_min_string=sprintf('%0.6f',yl(1));
y_max_string=sprintf('%0.6f',yl(2));

% throw up the dialog box
bounds=inputdlg({ sprintf('Y minimum:') , ...
                  sprintf('Y maximum:') },...
                'Set y axis bounds...',...
                1,...
                { y_min_string , y_max_string },...
                'off');
if ~isempty(bounds) 
  % break out the returned cell array                
  y_max_string=bounds{2};
  y_min_string=bounds{1};
  % convert all these strings to real numbers
  y_min=str2double(y_min_string);
  y_max=str2double(y_max_string);
  % if new values are kosher, change plot limits
  if ( ~isempty(y_min) && ~isempty(y_max) && ...
       isfinite(y_min) && isfinite(y_max) && ...
       (y_max>y_min) )
     for i=i_selected
       set(axes_hs(i),'YLim',[y_min y_max]);
     end
  end
end
