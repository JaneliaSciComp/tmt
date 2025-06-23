function set_tl_view(self,tl_view_new_want)

% save the new tl
self.tl_view=tl_view_new_want;

% refresh the traces on-screen to reflect the changed self.tl_view
self.refresh_traces();

% update the scrollbar to reflect the new time limits
self.scrollbar.set_tl_view(self.tl_view);
    
end
