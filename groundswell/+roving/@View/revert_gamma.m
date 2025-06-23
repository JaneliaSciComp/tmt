function revert_gamma(self)

cmap_name=self.cmap_name;
eval(sprintf('set(self.figure_h,''Colormap'',%s(256));',cmap_name));

end
