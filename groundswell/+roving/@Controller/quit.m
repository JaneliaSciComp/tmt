function quit(self)

self.stop_playing();
pause(0.01);
self.view.close();
self.model.close_video();

end
