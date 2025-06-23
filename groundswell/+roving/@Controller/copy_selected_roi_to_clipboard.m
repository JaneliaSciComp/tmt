function copy_selected_roi_to_clipboard(self)

i_selected=self.view.selected_roi_index;
if isempty(i_selected)
  return;
end
roi_selected=self.model.roi(i_selected);
border=roi_selected.border;
[~,n_vertex]=size(border);
border_centered=border-repmat(mean(border,2),[1 n_vertex]);
border_str=sprintf('%27.17g ',border_centered);
clipboard('copy',border_str);
self.view.roi_put_in_clipboard();

end
