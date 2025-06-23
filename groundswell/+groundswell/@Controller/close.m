function close(self)

% Close the current file.

% Check for unsaved data
if ~isempty(self.model) && ~self.model.saved
  if ismac()
    button=questdlg('Changes not saved.  Would you like to save changes?',...
                    'Save changes?',...
                    'Discard','Cancel','Save',...
                    'Save');
  else
    button=questdlg('Changes not saved.  Would you like to save changes?',...
                    'Save changes?',...
                    'Save','Discard','Cancel',...
                    'Save');
  end
  if strcmp(button,'Cancel')
    return;
  elseif strcmp(button,'Save')
    if self.model.file_native
      self.save(self.model.filename_abs);
    else
      saved=self.save_as();
      if ~saved
        % means user hit cancel in the 'save as' dialog box
        return;
      end
    end
  end
end

% clear the model
self.model=[];

% make the view reflect the "modified" model
self.view.completely_new_model(self.model);

end
