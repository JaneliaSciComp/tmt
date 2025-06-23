function step_right(self)

n_chan=self.model.n_chan;
if n_chan>0
  tl=self.model.tl;
  tl_view=self.view.tl_view;
  tw=tl_view(2)-tl_view(1);
  tf=tl(2);
  tl_view_new=tl_view+0.05*tw;
  if tl_view_new(2)>tf
    tl_view_new=[tf-tw tf];
  end
  self.set_tl_view(tl_view_new);
end
