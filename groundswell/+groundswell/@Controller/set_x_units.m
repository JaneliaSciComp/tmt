function set_x_units(self,new_x_units)

% set it in the view  
self.view.set_x_units(new_x_units);

% refresh the traces
self.view.set_tl_view(self.view.tl_view);

