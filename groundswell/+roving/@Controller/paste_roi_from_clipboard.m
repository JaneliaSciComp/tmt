function paste_roi_from_clipboard(self)

% Read the border out of the clipboard, and get it into the right shape.
border_str=clipboard('paste');
  % border_str, if it a ROI border, will be a list of vertex coords, a la:
  % x1 y1 x2 y2 ... xn yn
r_border_serial=sscanf(border_str,'%f');
n_numbers=length(r_border_serial);
if mod(n_numbers,2)~=0
  return;
end
n_vertex=round(n_numbers/2);
r_border=reshape(r_border_serial,[2 n_vertex]);

% If it's a valid border, the mean should be near-zero.  Return if
% that's not the case.
r_mean=mean(r_border,2);
if any(abs(r_mean)>0.1)
  return;
end

% Get the center of the image viewport.
[xl,yl]=self.view.get_image_viewport();
r_center=[mean(xl);mean(yl)];
  
% The new ROI will be at the center.
r_border=repmat(r_center,[1 n_vertex])+r_border;

% Add the new ROI
self.add_roi(r_border);

end
