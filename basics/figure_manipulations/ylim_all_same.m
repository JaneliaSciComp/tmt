function ylim_all_same(varargin)

% Make the y limits of all axes in figure fig to be the same, and wide enough
% to accomodate the data in each.

if isempty(varargin)
  error('Need at least one argument') ;
end
arg1 = varargin{1} ;
if ishghandle(arg1) && isprop(arg1, 'Type') && strcmp(arg1.Type, 'figure')
  fig = arg1 ;
  rest_of_args = varargin(2:end) ;
else
  fig = gcf() ;
  rest_of_args = varargin ;
end
[do_force_symmetric, do_include_zero] = ...
  parse_keyword_args(rest_of_args, ...
                     'do_force_symmetric', false, ...
                     'do_include_zero', false) ;
axes_h=get(fig,'children');
n_axes=length(axes_h);
yl_all=nan(n_axes,2);
for i=1:length(axes_h)
  ax = axes_h(i) ;
  yl_all(i,:)=ylim(ax);
end
raw_yl_min = min(yl_all(:,1)) ;
raw_yl_max = max(yl_all(:,2)) ;
% At this point, we know that raw_yl_max>=raw_yl_min
assert(raw_yl_max>=raw_yl_min) ;
[yl_min, yl_max] = ylim_all_same_helper(raw_yl_min, raw_yl_max, do_force_symmetric, do_include_zero) ;
assert(yl_max>=yl_min) ;
yl_common=[yl_min yl_max];
for i=1:length(axes_h)
  ax = axes_h(i) ;
  ylim(ax, yl_common);
end
