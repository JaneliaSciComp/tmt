function print_png_all(figs, res)

if nargin<1 || isempty(figs)
  figs = get(groot(),'Children')' ;
end
if nargin<2 
    res = [] ;
end

% print em
n = numel(figs) ;
for i = 1 : numel(figs)
  fig=figs(i) ;
  print_png(fig, [], res);
  if i<n
    fprintf('\n'); 
  end
end
