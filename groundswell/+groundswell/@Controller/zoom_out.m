function zoom_out(self)

n_chan=self.model.n_chan;
if n_chan>0
  tl=self.model.tl;
  tl_view=self.view.tl_view;
  tw=tl_view(2)-tl_view(1);
  t0=tl(1);  tf=tl(2);
  if tl_view(2)~=tf
    % the usual case -- zoom out by moving the right viewport limit
    tl_view_new=tl_view(1)+[0 2*tw];
    if tl_view_new(2)>tf
      tl_view_new(2)=tf;
    end
  elseif tl_view(1)~=t0
    % if we're hard against the right limit of the data, but not
    % the left limit, zoom out by moving the left limit of the viewport
    tl_view_new=[tf-2*tw tf];
    if tl_view_new(1)<t0
      tl_view_new(1)=t0;
    end
  else
    % can't zoom out on either end, the new viewport is same as old
    tl_view_new=tl_view;
  end
  % even if there's no change, we set the viewport, since sometimes
  % self.tl_view gets out of sync with the xlim of the axeses, 
  % especially if you click the zoom out button really fast
  self.set_tl_view(tl_view_new);  
end
