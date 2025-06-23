function completely_new_model(self,model)

% Called when the model changes completely, as when a new data file is
% loaded.
%
% Causes the view to re-sync itself to the new model, re-drawing basically
% everything.
%
% Note that the new model can be empty, as when the current file is closed.

% Change self.model to point to the new model
self.model=model;

% Notify sub-views that the model has changed
self.scrollbar.set_model(model);

% renew the axes
self.renew_axes();

% call resize() to draw the axes
self.resize();

% set the view limits to the full time range
% (this will also trigger ploting of the traces with subsetting and
% subsampling)
if ~isempty(model)
  self.set_tl_view(self.model.tl);
end

% enable controls as necessary
self.update_enablement_of_controls();

% Notify the view that the filename/filename synch state has changed.
self.update_title_bar();

end
