function set_tl_view(self,tl_view_new_want)

% if tl_view_new_want is empty, do nothing
if isempty(tl_view_new_want)
  return;
end

% make sure right order
tl_view_new_want_srt=sort(tl_view_new_want); 

% limit to data bounds
tl=self.model.tl;
t0=tl(1);
tf=tl(2);
tl_view_new_want_srt_constrained(1)=...
  min(max(tl_view_new_want_srt(1),t0),tf);
tl_view_new_want_srt_constrained(2)=...
  min(max(tl_view_new_want_srt(2),t0),tf);

% make sure the bounds are still valid
if tl_view_new_want_srt_constrained(1)==tl_view_new_want_srt_constrained(2)
  return;
end

% if we get here, tl_view_new_want_srt_constrained is valid

% set the new tl in the view
self.view.set_tl_view(tl_view_new_want_srt_constrained);

end
