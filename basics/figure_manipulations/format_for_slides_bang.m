function format_for_slides_bang(fig, font_size)
    if nargin < 1
        fig = gcf() ;
    end
    if nargin < 2
        font_size = 16; % Default font size
    end

    axeses = findall(fig, 'Type', 'axes') ;
    for i = 1 : numel(axeses)
      ax = axeses(i) ;
      ax.FontSize = font_size;
      ax.XLabel.FontSize = font_size + 2;
      ax.YLabel.FontSize = font_size + 2;
      ax.Title.FontSize = font_size + 4;
      ax.LineWidth = 1.5;      
      lines = findall(ax, 'Type', 'line') ;
      for j = 1 : numel(lines) 
        line = lines(j) ;
        line.LineWidth = 1.5 ;
      end
    end
end
