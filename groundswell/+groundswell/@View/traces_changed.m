function traces_changed(self)

% The traces have changed, so update the view appropriately.

force_resample=true;
self.refresh_traces(force_resample);
self.update_title_bar();
self.update_enablement_of_controls();

end
