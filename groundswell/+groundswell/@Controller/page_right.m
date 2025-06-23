function page_right(self)

if ~isempty(self.view.axes_hs)
  tl=self.model.tl;
  tl_view=self.view.tl_view;
  tw=tl_view(2)-tl_view(1);
  tf=tl(2);
  tl_view_new=tl_view+tw;
  if tl_view_new(2)>tf
    tl_view_new=[tf-tw tf];
  end
  self.set_tl_view(tl_view_new);
end
