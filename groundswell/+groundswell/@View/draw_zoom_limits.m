function draw_zoom_limits(self,action,axes_h_init)

persistent fig_h;
persistent axes_h;
persistent axes_hs;
persistent anchor;
persistent anchor_line_hs;
persistent point_line_hs;
persistent n;

if nargin<3
  axes_h_init=gcbo;
end

switch(action)
  case 'start'
    axes_h=axes_h_init;
    fig_h=get(axes_h,'parent');
    axes_hs=self.axes_hs;
    cp=get(axes_h,'CurrentPoint');
    point=cp(1,1:2);
    anchor=point;
    % create new limit lines
    n=length(axes_hs);
    anchor_line_hs=zeros(n,1);
    point_line_hs=zeros(n,1);
    for i=1:n  
      yl=ylim(axes_hs(i));
      anchor_line_hs(i)=...
        line('Parent',axes_hs(i),...
             'Color',[0.25 0.25 0.25],...
             'Tag','anchor_line_h',...
             'XData',[anchor(1) anchor(1)],...
             'YData',yl,...
             'ZData',[2 2]);
      point_line_hs(i)=...
        line('Parent',axes_hs(i),...
             'Color',[0.25 0.25 0.25],...
             'Tag','point_line_h',...
             'XData',[point(1) point(1)],...
             'YData',yl,...
             'ZData',[2 2]);
    end
    % set the callbacks for the drag
    set(fig_h,'WindowButtonMotionFcn',...
              @(src,evt)(self.draw_zoom_limits('move')));
    set(fig_h,'WindowButtonUpFcn',...
              @(src,evt)(self.draw_zoom_limits('stop')));
  case 'move'
    cp=get(axes_h,'CurrentPoint');
    point=cp(1,1:2);
    for i=1:n
      set(point_line_hs(i),...
          'XData',[point(1) point(1)]);
    end
  case 'stop'
    % change the move and buttonup calbacks
    set(fig_h,'WindowButtonMotionFcn','');
    set(fig_h,'WindowButtonUpFcn','');
    % now do the stuff we'd do for a move also
    cp=get(axes_h,'CurrentPoint');
    point=cp(1,1:2); 
    for i=1:n
      set(point_line_hs(i),...
          'XData',[point(1) point(1)]);
    end
    % now do the zoom
    if anchor(1)~=point(1)
      xl_view_new=[anchor(1) point(1)];
      tl_view_new=self.t_from_x(xl_view_new);
      self.controller.set_tl_view(tl_view_new);
    end
    % clear the persistents
    fig_h=[];
    axes_h=[];
    axes_hs=[];    
    % now delete the lines
    delete(anchor_line_hs);
    delete(point_line_hs);    
end  % switch






