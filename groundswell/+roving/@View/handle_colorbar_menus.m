function handle_colorbar_menus(self,tag)

% switch on the tag
i=self.frame_index;
switch(tag)
  case 'pixel_data_type_min_max'
    [d_min,d_max]=self.model.pixel_data_type_min_max();
    self.set_colorbar_bounds_from_numbers(d_min,d_max);         
  case 'min_max'
    self.hourglass();
    [d_min,d_max]=self.model.min_max(i);
    self.unhourglass();
    self.set_colorbar_bounds_from_numbers(d_min,d_max);         
  case 'five_95'
    self.hourglass();
    [d_05,d_95]=self.model.five_95(i);
    d_05=floor(d_05);  % want int, want to span range
    d_95=ceil(d_95);  % want int, want to span range
    self.unhourglass();
    self.set_colorbar_bounds_from_numbers(d_05,d_95);         
  case 'abs_max'
    self.hourglass();
    cb_max=self.model.max_abs(i);
    self.unhourglass();
    self.set_colorbar_bounds_from_numbers(-cb_max,+cb_max);         
  case 'ninety_symmetric'
    % need to fix this, since what it does now is useless
    self.hourglass();
    cb_max=ceil(self.model.abs_90(i));
    cb_min=-cb_max; 
    self.unhourglass();
    self.set_colorbar_bounds_from_numbers(cb_min,cb_max);         
  case 'colorbar_edit_bounds'
    % get the current y min and y max strings
    cb_min_string=self.colorbar_min_string;
    cb_max_string=self.colorbar_max_string;
    % throw up the dialog box
    bounds=inputdlg({ 'Colorbar Maximum:' , 'Colorbar Minimum:' },...
                    'Edit Colorbar Bounds...',...
                    1,...
                    { cb_max_string , cb_min_string });
    if isempty(bounds) 
      return; 
    end
    % break out the returned cell array                
    new_cb_max_string=bounds{1};
    new_cb_min_string=bounds{2};
    % convert all these strings to real numbers
    %cb_min=str2double(cb_min_string);
    %cb_max=str2double(cb_max_string);
    new_cb_min=floor(str2double(new_cb_min_string));
    new_cb_max=ceil(str2double(new_cb_max_string));
    % if new values are kosher, change colorbar bounds
    if ~isempty(new_cb_min) && ~isempty(new_cb_max) && ...
       isfinite(new_cb_min) && isfinite(new_cb_max) && ...
       (new_cb_max>new_cb_min)
      self.set_colorbar_bounds_from_numbers(new_cb_min,new_cb_max);
    end
end  
