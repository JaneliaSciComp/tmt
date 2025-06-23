function set_selected_axes(self,i_selected_new)

% Set which axes are currently selected.

% get stuff from the figure                                   
axes_hs=self.axes_hs;
i_selected_old=self.i_selected;

% which have axes have changed their selection state?
i_changed=setxor(i_selected_old,i_selected_new);

% cycle through changed axes and update the display
for i=i_changed
  y_label_h=get(axes_hs(i),'ylabel');  % handle of text object
  if any(i==i_selected_new)
    set(y_label_h,'fontweight','bold');
    set(y_label_h,'backgroundcolor','w');
    set(y_label_h,'edgecolor','k');
  else
    set(y_label_h,'fontweight','normal');
    set(y_label_h,'backgroundcolor','none');
    set(y_label_h,'edgecolor','none');
  end
end

% change the last selected, new and old
if ~isempty(i_selected_old)
  i_selected_last_old=i_selected_old(end);
  y_label_h=get(axes_hs(i_selected_last_old),'ylabel');  % handle of text object
  %set(y_label_h,'fontangle','normal');
  set(y_label_h,'linewidth',1);
end
if ~isempty(i_selected_new)
  i_selected_last_new=i_selected_new(end);
  y_label_h=get(axes_hs(i_selected_last_new),'ylabel');  % handle of text object
  %set(y_label_h,'fontangle','italic');
  set(y_label_h,'linewidth',2);
end

% % update the display
% drawnow('update');
% drawnow('expose');

% store stuff in self
self.i_selected=i_selected_new;

% enable/disable controls
self.update_enablement_of_controls();

end
