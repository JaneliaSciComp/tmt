function print_eps(fig_h,basename)

% prints to an EPS file

tic
if nargin<1 || isempty(fig_h)
  fig_h=gcf;
end
if nargin<2 || isempty(basename)
  if isempty(get(fig_h,'name'))
    basename=sprintf('fig-%03d',fig_h);
  else
    basename=get(fig_h,'name');
  end
end
fprintf(1,'%s:\n',basename);
%print(fig_h,'-depsc2','-loose','-adobecset',sprintf('%s.eps',basename));
print(fig_h,'-depsc2','-loose',sprintf('%s.eps',basename));
t=toc;
fprintf(1,'Elapsed time: %0.1f sec\n',t);
