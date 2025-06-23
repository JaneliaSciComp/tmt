function quit(self)

% Close the file, if needed
self.close();

% Tell the view wassup.
self.view.quit_requested();

end
