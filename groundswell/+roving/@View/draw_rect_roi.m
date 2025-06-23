function draw_rect_roi(self,action)

persistent anchor;
persistent rect_h;
persistent square;

switch(action)
  case 'start'
    cp=get(self.image_axes_h,'CurrentPoint');
    point=cp(1,1:2); 
    anchor=point;
    square=strcmp(get(self.figure_h,'selectiontype'),'extend');
    % create a new rectangle
    rect_h=...
      line('Parent',self.image_axes_h,...
           'Color',[1 0 0],...
           'Tag','border_h',...
           'XData',[anchor(1) anchor(1) point(1) point(1)  anchor(1)],...
           'YData',[anchor(2) point(2)  point(2) anchor(2) anchor(2)],...
           'ZData',[2 2 2 2 2],...
           'ButtonDownFcn',@(src,event)(self.mouse_button_down_in_image()));
    % set the callbacks for the drag
    set(self.figure_h,'WindowButtonMotionFcn',...
                 @(src,event)(self.draw_rect_roi('move')));
    set(self.figure_h,'WindowButtonUpFcn',...
                 @(src,event)(self.draw_rect_roi('stop')));
  case 'move'
    cp=get(self.image_axes_h,'CurrentPoint');
    point=cp(1,1:2);
    w=(point(1)-anchor(1));
    h=(point(2)-anchor(2));
    if square
      s=max(abs(w),(h));
      w=sign(w)*s;
      h=sign(h)*s;
    end
    set(rect_h,...
        'XData',anchor(1)+[0 w w 0 0]);
    set(rect_h,...
        'YData',anchor(2)+[0 0 h h 0]);
  case 'stop'
    % change the move and buttonup calbacks
    set(self.figure_h,'WindowButtonMotionFcn',@(src,event)(self.update_pointer()));
    set(self.figure_h,'WindowButtonUpFcn',[]);
    % now do the stuff we'd do for a move also
    cp=get(self.image_axes_h,'CurrentPoint');
    point=cp(1,1:2); 
    w=(point(1)-anchor(1));
    h=(point(2)-anchor(2));
    if square
      s=max(abs(w),(h));
      w=sign(w)*s;
      h=sign(h)*s;
    end
    set(rect_h,...
        'XData',anchor(1)+[0 w w 0 0]);
    set(rect_h,...
        'YData',anchor(2)+[0 0 h h 0]);
    % now add the roi to the list
    self.controller.add_roi_given_line_gh(rect_h);
end  % switch

end
