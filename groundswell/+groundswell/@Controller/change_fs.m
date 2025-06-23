function change_fs(self)

% get the current fs_str
fs_str=self.fs_str;

% throw up the dialog box
fs_str_new=inputdlg({ 'New sampling frequency (Hz):' },...
                      'Change sampling frequency...',...
                      1,...
                      { fs_str },...
                      'off');
if ~isempty(fs_str_new) 
  % break out the returned cell array                
  fs_str_new=fs_str_new{1};
  % convert all these strings to real numbers
  fs_new=str2double(fs_str_new);
  % if new values are kosher, change plot limits
  if ( ~isempty(fs_new) && ...
       isfinite(fs_new) && ...
       (fs_new>0) )
     self.fs_str=fs_str_new;
     self.model.fs=fs_new;
     self.view.fs_has_changed();
  end
end

end
