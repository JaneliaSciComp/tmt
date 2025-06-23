function print_pdf_all()

% print em
figs=get(groot(),'Children')';
n = numel(figs) ;
for i = 1 : numel(figs)
  fig=figs(i) ;
  print_pdf(fig);
  if i<n
    fprintf('\n'); 
  end
end
