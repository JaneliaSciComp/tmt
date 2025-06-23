function ylim_all(varargin)

if isempty(varargin)
  error('Need at least one argument') ;
end
arg1 = varargin{1} ;
if ishghandle(arg1) && isprop(arg1, 'Type') && strcmp(arg1.Type, 'figure')
  fig = arg1 ;
  yl = varargin{2} ;
else
  fig = gcf() ;
  yl = varargin{1} ;
end

axes_h=get(fig,'children');
for i=1:length(axes_h)
  ax = axes_h(i) ;
  ylim(ax,yl);
end
