function handle_focus_gained(self)

% update the command-key state
%fprintf('focus gained\n');
self.command_depressed=false;  % this may or may not really be correct,
                               % but it's best to assume this, so that
                               % user doesn't automatically do a
                               % non-contiguous extend next time they click
                               % to select a signal.

end
