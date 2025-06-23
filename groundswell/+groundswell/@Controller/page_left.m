function page_left(self)

n_chan=self.model.n_chan;
if n_chan>0
  tl=self.model.tl;
  tl_view=self.view.tl_view;
  tw=tl_view(2)-tl_view(1);
  t0=tl(1);
  tl_view_new=tl_view-tw;
  if tl_view_new(1)<t0
    tl_view_new=[t0 t0+tw];
  end
  self.set_tl_view(tl_view_new);
end
