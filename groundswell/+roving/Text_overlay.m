classdef Text_overlay

  properties
    x;
    y;
    string;
    color;
    size;
  end  % properties
  
  properties (Dependent=true)
  end
  
  methods
    function self=Text_overlay(x,y,string,color,sz)
      if nargin<5 || isempty(sz)
        sz=10;  % default font size (in pels, assuming 72 ppi screen)
      end
      self.x=x;
      self.y=y;
      self.string=string;
      self.color=color;
      self.size=sz;
    end
    
    function h=draw_into_axes(self,axes_h)
      h=text('parent',axes_h,...
             'position',[self.x self.y], ...
             'fontsize',self.size,...
             'string',self.string, ...
             'fontweight','bold',...
             'color',self.color);
    end
    
  end  % methods

end  % classdef
