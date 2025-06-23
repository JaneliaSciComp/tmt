function set_colorbar_bounds_from_strings(self,cb_min_string,cb_max_string)

% Set the view colorbar bounds given max and min values in strings.  No
% checking is done to make sure the string values are sane.  Note that in
% the view, although both string and numerical representations of the 
% colorbar bounds are maintained, the string ones are the more fundamental,
% and the numerical ones are derived from them.  At the moment, this
% doesn't matter much, since the bounds are constrained to always be 
% integral.  But if we support movies with floating-point pels at some
% point, this will be important, since the user can explicitly set the
% bounds, and we want to keep hold of _exactly_ what the user typed.

% change the figure strings
self.colorbar_min_string=cb_min_string;
self.colorbar_max_string=cb_max_string;

% change the axes and colorbar
cb_min=str2double(cb_min_string);
cb_max=str2double(cb_max_string);
set(self.colorbar_axes_h,'YLim',[cb_min cb_max]);
% cb_increment=(cb_max-cb_min)/256;
% set(self.colorbar_h,'YData',[cb_min+0.5*cb_increment...
%                              cb_max-0.5*cb_increment]);
set(self.colorbar_h,'YData',[cb_min cb_max]);

% store the translated vals in self
self.colorbar_min=cb_min;
self.colorbar_max=cb_max;

% recalculate indexed_frame, set in figure
if self.model.a_video_is_open ,
  % change the displayed image
  set(self.image_h,'CData',self.indexed_frame);
end

end
