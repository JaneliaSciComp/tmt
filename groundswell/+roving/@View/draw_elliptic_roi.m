function draw_elliptic_roi(self,action)

persistent figure_h;
persistent image_axes_h;
persistent anchor;
persistent ellipse_h;
persistent n_segs;
persistent sintheta;
persistent costheta;
persistent circle;  % boolean

% init the persistents that point to the image figure and the image axes, if
% this is the first time through this function
if isempty(figure_h)
  figure_h=self.figure_h;
end  
if isempty(image_axes_h)
  image_axes_h=self.image_axes_h;
end  
if isempty(n_segs)
  n_segs=40;
  theta=linspace(0,2*pi,n_segs+1);
  sintheta=sin(theta);
  costheta=cos(theta);
end

% the big switcheroo  
switch(action)
  case 'start'
    cp=get(image_axes_h,'CurrentPoint');
    point=cp(1,1:2); 
    anchor=point;
    circle=strcmp(get(figure_h,'selectiontype'),'extend');
    % create a new 'ellipse'
    ellipse_h=...
      line('Parent',image_axes_h,...
           'Color',[1 0 0],...
           'Tag','border_h',...
           'XData',repmat(anchor(1),[1 n_segs+1]),...
           'YData',repmat(anchor(2),[1 n_segs+1]),...
           'ZData',repmat(2,[1 n_segs+1]),...
           'ButtonDownFcn',@(src,event)(self.mouse_button_down_in_image()));
    % set the callbacks for the drag
    set(figure_h,'WindowButtonMotionFcn',...
                 @(src,event)(self.draw_elliptic_roi('move')));
    set(figure_h,'WindowButtonUpFcn',...
                 @(src,event)(self.draw_elliptic_roi('stop')));
  case 'move'
    cp=get(image_axes_h,'CurrentPoint');
    point=cp(1,1:2); 
    a=(point(1)-anchor(1)); 
    b=(point(2)-anchor(2));
    if circle
      r=max(a,b);
      a=r;
      b=r;
    end
    %center=anchor+[a b];
    center=anchor;    
    dx=a*costheta;
    dy=b*sintheta;
    set(ellipse_h,'XData',center(1)+dx);
    set(ellipse_h,'YData',center(2)+dy);
  case 'stop'
    % change the move and buttonup callbacks
    set(figure_h,'WindowButtonMotionFcn',@(src,event)(self.update_pointer()));
    set(figure_h,'WindowButtonUpFcn',[]);
    % now do the stuff we'd do for a move also
    cp=get(image_axes_h,'CurrentPoint');
    point=cp(1,1:2); 
    a=(point(1)-anchor(1)); 
    b=(point(2)-anchor(2));
    if circle
      r=max(a,b);
      a=r;
      b=r;
    end
    %center=anchor+[a b];
    center=anchor;
    dx=a*costheta;
    dy=b*sintheta;
    set(ellipse_h,'XData',center(1)+dx);
    set(ellipse_h,'YData',center(2)+dy);
    % clear the persistents
    figure_h=[];
    image_axes_h=[];
    % now add the roi to the list
    self.controller.add_roi_given_line_gh(ellipse_h);
end  % switch

end
