function to_end(self)

n_chan=self.model.n_chan;
if n_chan>0
  tl=self.model.tl;
  tl_view=self.view.tl_view;
  tw=tl_view(2)-tl_view(1);
  tf=tl(2);
  self.set_tl_view([tf-tw tf]);
end
