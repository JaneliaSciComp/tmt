function renew_axes(self)

% called when the number of signals has changed, and the number of axes 
% needs to be changed to reflect this
% we assume all the self data-related instance vars are up-to-date and 
% consistent

% get instance vars we need
axes_hs=self.axes_hs;
colors=self.colors;

% delete any axes that currently exist
delete(axes_hs);
self.axes_hs=zeros(0,1);

% Usual case is a non-empty model
if ~isempty(self.model)  
  % Extract parts of model
  t=self.model.t;
  data=self.model.data;
  names=self.model.names;
  units=self.model.units;

  % get dims
  [n_t,n_chan,n_sweeps]=size(data);
  tl=[t(1) t(end)];

  % make the callbacks
  axes_cb=@(src,evt)(self.draw_zoom_limits('start'));
  chan_label_cb=@(src,evt)(self.controller.handle_axes_selection(src));

  % make new axes
  axes_hs=zeros(n_chan,1);
  for i=1:n_chan
    tag=sprintf('axes_hs(%d)',i);
    axes_hs(i)=axes('Parent',self.fig_h,...
                    'Tag',tag,...
                    'Units','pixels',...
                    'Box','on',...
                    'Layer','Top',...
                    'visible','off',...
                    'color','w',...
                    'ButtonDownFcn',axes_cb);  %#ok
    if i<n_chan
      set(gca,'XTickLabel',{});
    else
      x_label_h = xlabel('Time (s)','tag','x_axis_label','FontSize',10) ;
      disable_interactions_bang(x_label_h) ;
    end
  end

  % store the axes in the object
  self.axes_hs=axes_hs;

  % put dummy signals in the axes
  y_label_h=zeros(n_chan,1);
  for i=1:n_chan
    set(axes_hs(i),'XLim',tl);
    data_this=reshape(data(:,i,:),[n_t n_sweeps]);
    y_min=min(min(data_this));  y_max=max(max(data_this));
    y_mid=(y_min+y_max)/2;  y_radius=(y_max-y_min)/2;
    if y_radius==0
      y_radius=1;
    end
    y_lo=y_mid-1.1*y_radius;  y_hi=y_mid+1.1*y_radius;
    if ~isfinite(y_lo) || ~isfinite(y_hi)
      y_lo=-1;
      y_hi=+1;
    end
    set(axes_hs(i),'YLim',[y_lo y_hi]);
    set(self.fig_h,'currentaxes',axes_hs(i));
    if isempty(units{i})
      label_str=names{i};
    else
      label_str=sprintf('%s (%s)',names{i},units{i});
    end
    y_label_h(i)=ylabel(label_str,...
                        'interpreter','none',...
                        'tag','y_axis_label',...
                        'verticalalignment','baseline',...
                        'units','pixels',...
                        'FontSize',10, ...
                        'buttondownfcn',chan_label_cb);
    disable_interactions_bang(y_label_h(i)) ;
    n_sweeps=size(data_this,2);
    for j=1:n_sweeps
      line('Parent',axes_hs(i),...
           'XData',tl,...
           'YData',zeros(size(tl)),...
           'Color',colors(i,:),...
           'Tag','trace',...
           'visible','off');
    end
  end
  %drawnow('expose');
  %drawnow('update');
end

% nothing is selected, since everything is new
self.i_selected=zeros(0,1);

% set subsampling-related instance vars to "undefined"
self.r=1;
self.t_sub=[];
self.data_sub_min=[];
self.data_sub_max=[];

end
