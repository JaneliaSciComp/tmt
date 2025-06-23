function update_enablement_of_controls(self)

% this enables/disables all elements of the main window to properly 
% reflect the current state of the view object

% get vars we need
i_selected=self.i_selected;
n_selected=length(i_selected);

if isempty(self.model) || self.model.n_chan==0
  % file menu
  set(self.open_menu_h,'enable','on');
  set(self.import_menu_h,'enable','on');
  set(self.close_menu_h,'enable','off');
  set(self.add_synced_data_menu_item_h,'enable','off');
  set(self.add_synced_data_ft_menu_item_h,'enable','off');
  %set(self.add_presynched_traces_menu_item_h,'enable','off');
  set(self.save_menu_h,'enable','off');
  set(self.save_as_menu_h,'enable','off');  
  set(self.revert_menu_h,'enable','off');
  % edit menu
  set(self.select_all_menu_h,'enable','off');
  set(self.select_none_menu_h,'enable','off');
  set(self.invert_selection_menu_h,'enable','off');
  % x axis menu
  set(self.time_ms_menu_h,'enable','off');
  set(self.time_s_menu_h,'enable','off');
  set(self.time_min_menu_h,'enable','off');
  set(self.time_hr_menu_h,'enable','off');
  set(self.edit_t_bounds_menu_h,'enable','off');
  % y axis menu
  set(self.optimize_all_y_menu_h,'enable','off');
  % buttons
  set(self.to_start_button_h,'enable','off');
  set(self.page_left_button_h,'enable','off');
  set(self.step_left_button_h,'enable','off');
  set(self.step_right_button_h,'enable','off');
  set(self.page_right_button_h,'enable','off');
  set(self.to_end_button_h,'enable','off');
  set(self.zoom_way_out_button_h,'enable','off');
  set(self.zoom_out_button_h,'enable','off');
  set(self.zoom_in_button_h,'enable','off');
  % mutation menu
  set(self.change_fs_menu_h,'enable','off');
  set(self.center_menu_h,'enable','off');
  set(self.rectify_menu_h,'enable','off');
  % analysis menu
  %set(self.analysis_menu_h,'enable','off');  
  set(self.power_spectrum_menu_h,'enable','off');
  set(self.spectrogram_menu_h,'enable','off');  
  set(self.coherency_menu_h,'enable','off');
  set(self.coherency_at_f_probe_menu_h,'enable','off');
  set(self.coherogram_menu_h,'enable','off');
  set(self.transfer_function_menu_h,'enable','off');
  set(self.play_as_audio_menu_h,'enable','off');
  set(self.count_ttl_edges_menu_h,'enable','off');
  % scrollbar
  self.scrollbar.set_visible('off');
else
  % file menu
  if ~isempty(self.model.filename_abs) && self.model.file_native && ...
     ~self.model.saved
    set(self.save_menu_h,'enable','on');
    set(self.open_menu_h,'enable','off');
    set(self.import_menu_h,'enable','off');
    set(self.revert_menu_h,'enable','on');  
  else
    set(self.save_menu_h,'enable','off');
    set(self.open_menu_h,'enable','on');
    set(self.import_menu_h,'enable','on');
    set(self.revert_menu_h,'enable','off');  
  end
  %set(self.add_presynched_traces_menu_item_h,'enable','on');  
  set(self.save_as_menu_h,'enable','on');  
  set(self.close_menu_h,'enable','on');
  % edit menu
  set(self.select_all_menu_h,'enable','on');
  set(self.select_none_menu_h,'enable','on');
  set(self.invert_selection_menu_h,'enable','on');
  % x axis menu
  set(self.time_ms_menu_h,'enable','on');
  set(self.time_s_menu_h,'enable','on');
  set(self.time_min_menu_h,'enable','on');
  set(self.time_hr_menu_h,'enable','on');
  set(self.edit_t_bounds_menu_h,'enable','on');
  % y axis menu
  set(self.optimize_all_y_menu_h,'enable','on');
  % buttons
  set(self.to_start_button_h,'enable','on');
  set(self.page_left_button_h,'enable','on');
  set(self.step_left_button_h,'enable','on');
  set(self.step_right_button_h,'enable','on');
  set(self.page_right_button_h,'enable','on');
  set(self.to_end_button_h,'enable','on');
  set(self.zoom_way_out_button_h,'enable','on');
  set(self.zoom_out_button_h,'enable','on');
  set(self.zoom_in_button_h,'enable','on');
  % mutation menu
  set(self.change_fs_menu_h,'enable','on');
  if n_selected==0
    % y axis menu
    set(self.edit_y_bounds_menu_h,'enable','off');
    set(self.optimize_selected_y_menu_h,'enable','off');
    % mutation menu
    set(self.center_menu_h,'enable','off');
    set(self.rectify_menu_h,'enable','off');
    set(self.dx_over_x_menu_h,'enable','off');
  else    
    % y axis menu
    set(self.edit_y_bounds_menu_h,'enable','on');
    set(self.optimize_selected_y_menu_h,'enable','on');
    % mutation menu
    set(self.center_menu_h,'enable','on');
    set(self.rectify_menu_h,'enable','on');
    set(self.dx_over_x_menu_h,'enable','on');
  end
  if n_selected==1
    % file menu
    set(self.add_synced_data_menu_item_h,'enable','on');
    set(self.add_synced_data_ft_menu_item_h,'enable','on');
    % analysis menu
    set(self.power_spectrum_menu_h,'enable','on');
    set(self.spectrogram_menu_h,'enable','on');  
    set(self.play_as_audio_menu_h,'enable','on');
    set(self.count_ttl_edges_menu_h,'enable','on');      
  else
    % file menu
    set(self.add_synced_data_menu_item_h,'enable','off');
    set(self.add_synced_data_ft_menu_item_h,'enable','off');
    % analysis menu
    set(self.power_spectrum_menu_h,'enable','off');
    set(self.spectrogram_menu_h,'enable','off');  
    set(self.play_as_audio_menu_h,'enable','off');
    set(self.count_ttl_edges_menu_h,'enable','off');
  end    
  if n_selected==2
    % analysis menu
    set(self.coherency_menu_h,'enable','on');
    set(self.coherogram_menu_h,'enable','on');
    set(self.transfer_function_menu_h,'enable','on');
  else
    % analysis menu
    set(self.coherency_menu_h,'enable','off');
    set(self.coherogram_menu_h,'enable','off');
    set(self.transfer_function_menu_h,'enable','off');
  end
  if n_selected>=2
    set(self.coherency_at_f_probe_menu_h,'enable','on');
  else
    set(self.coherency_at_f_probe_menu_h,'enable','off');
  end  
  % scrollbar
  self.scrollbar.set_visible('on');
end
