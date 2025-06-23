function handle_key_release(self,event)

% update the shift state, if needed
%fprintf('some key released\n');
if isempty(event.Character) && isempty(event.Modifier) && ...
   strcmp(event.Key,'0')
  %fprintf('command released\n');
  self.command_depressed=false;
end

end
