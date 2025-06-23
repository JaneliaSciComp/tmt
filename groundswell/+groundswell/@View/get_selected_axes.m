function selected=get_selected_axes(self)

i_selected=self.i_selected;
n_chan=self.model.n_chan;
selected=false(n_chan,1);
selected(i_selected)=true;
