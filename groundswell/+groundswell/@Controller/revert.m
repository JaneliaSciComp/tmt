function revert(self)

% Check for unsaved data
if ~isempty(self.model) && ~self.model.saved
  if ismac()
    button=questdlg('Revert to saved version?  If you revert, you will lose unsaved changes.',...
                    'Revert?',...
                    'Cancel','Revert',...
                    'Cancel');
  else
    button=questdlg('Revert to saved version?  If you revert, you will lose unsaved changes.',...
                    'Revert?',...
                    'Revert','Cancel',...
                    'Cancel');
  end
  if strcmp(button,'Cancel')
    return;
  end
end

% open the current file
self.open(self.model.filename_abs);

end
