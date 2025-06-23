function invert_selection(self)

selected=self.view.get_selected_axes();  % col vector
i_selected_new=find(~selected)';
self.view.set_selected_axes(i_selected_new);

end  % function
