function motion_correct(self)

self.view.hourglass();
self.model.motion_correct();
self.view.model_data_changed();
self.view.unhourglass();

end
