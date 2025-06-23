function darken(self)

cmap=get(self.figure_h,'Colormap');
new_cmap=brighten(cmap,-0.1);
set(self.figure_h,'Colormap',new_cmap);

end
