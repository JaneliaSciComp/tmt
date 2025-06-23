function zoom_in(self)

n_chan=self.model.n_chan;
if n_chan>0
  tl_view=self.view.tl_view;
  tw=tl_view(2)-tl_view(1);
  tl_view_new=tl_view(1)+[0 tw/2];
  self.set_tl_view(tl_view_new);
end
