function select_all(self)

selected=self.view.get_selected_axes();  % col vector
i_new=find(~selected)';
i_selected_new=[self.view.i_selected i_new];
self.view.set_selected_axes(i_selected_new);

end  % function
