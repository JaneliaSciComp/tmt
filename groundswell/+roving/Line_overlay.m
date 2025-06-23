classdef Line_overlay

  properties
    x;
    y;
    width;
    color;
  end  % properties
  
  properties (Dependent=true)
  end
  
  methods
    function self=Line_overlay(x,y,width,color)
      self.x=x;
      self.y=y;
      self.width=width;
      self.color=color;
    end
        
    function h=draw_into_axes(self,axes_h)
      h=line('parent',axes_h, ...
             'xdata',self.x, ...
             'ydata',self.y, ...
             'linewidth',self.width, ...
             'color',self.color);
    end
    
  end  % methods

end  % classdef
