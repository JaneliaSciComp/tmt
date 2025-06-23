classdef Polygonal_roi < handle

  properties
    % state of polgonal ROI being drawn
    parent;  % an instance of roving.View, which contains this thing
    vertex;
    polygon_h;
  end  % properties
  
  properties (Dependent=true)
    n_vertices
  end
  
  methods
    function self=Polygonal_roi(parent)
      self.parent=parent;
      self.vertex=zeros(2,0);
      self.polygon_h=[];
      % set the mouse-up callback
      set(self.parent.figure_h,'WindowButtonUpFcn',...
            @(src,event)(self.parent.draw_polygonal_roi('up')));
    end  % constructor
    
    function result=get.n_vertices(self)
      result=size(self.vertex,2);
    end

    function result=distance_to_first_vertex(self,point)
      n_vertices=size(self.vertex,2);
      if n_vertices>0
        result=norm(point-self.vertex(:,1));
      else
        result=nan;
      end
    end
      
    function append(self,point)
      self.vertex=[self.vertex point];
      n_vertices=size(self.vertex,2);
      if n_vertices==1
        % if first vertex, create the line GH object
        self.polygon_h=...
          line('Parent',self.parent.image_axes_h,...
               'Color',[1 0 0],...
               'Marker','.', ...
               'MarkerSize',3*2);      
      end
      set(self.polygon_h,'XData',self.vertex(1,:), ...
                         'YData',self.vertex(2,:), ...
                         'ZData',repmat(2,[1 n_vertices]));
    end
    
    function commit(self)
      % now finish off the polygon
      n_vertices=size(self.vertex,2);
      set(self.polygon_h, ...
            'XData',[self.vertex(1,:) self.vertex(1,1)], ...
            'YData',[self.vertex(2,:) self.vertex(2,1)], ...
            'ZData',repmat(2,[1 n_vertices+1]), ...
            'Marker','none', ...
            'ButtonDownFcn', ...
              @(src,event)(self.parent.mouse_button_down_in_image()));
      % now add the roi to the list
      self.parent.controller.add_roi_given_line_gh(self.polygon_h);
      % clear the mouse-up callback
      set(self.parent.figure_h,'WindowButtonUpFcn',[]);
      % reset things, to avoid trouble
      self.polygon_h=[];
      self.vertex=zeros(2,0);
    end

    function clear(self)
      % Reset the Polygonal_roi to its just-born state.
      % clear the mouse-up callback
      set(self.parent.figure_h,'WindowButtonUpFcn',[]);
      % if there's a nonempty line handle, delete the object
      delete(self.polygon_h);
      self.vertex=zeros(2,0);
    end      
  end  % methods

  methods (Access=private)
  end  % methods
  
end  % classdef
