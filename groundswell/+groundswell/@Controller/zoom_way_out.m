function zoom_way_out(self)

n_chan=self.model.n_chan;
if n_chan>0
  tl=self.model.tl;
  self.set_tl_view(tl);
end
