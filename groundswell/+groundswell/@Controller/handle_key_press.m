function handle_key_press(self,event)

% update the shift state, if needed
if ~isempty(event.Modifier) && strcmp(event.Modifier{1},'command')
  %fprintf('command pressed\n');
  self.command_depressed=true;
end

end
