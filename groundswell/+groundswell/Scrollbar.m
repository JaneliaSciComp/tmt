classdef Scrollbar < handle

% This is Scrollbar, a class to represent the scrollbar within the 
% groundswell main window (and hence a view).

  properties
    view;  % the main groundswell view
    model;  % the main groundswell model
    % graphics handle to the slide uicontrol
    scrollbar_h
  end  % properties
  
  methods
    function self=Scrollbar(view)      
      self.view=view;
      self.model=[];
      
      % create the GUI object (a matlab slider) 
      self.scrollbar_h = ...
        uicontrol('Parent',self.view.fig_h,...
                  'Style','slider',...
                  'Visible','off',...
                  'Tag','scrollbar_h');
                
      % register the callback
      set(self.scrollbar_h,'Callback', ...
                           @(src,event)(self.something_manipulated_you()));
    end  % constructor

    function set_model(self,model)
      self.model=model;
    end
    
    function set_visible(self,visibility)
      set(self.scrollbar_h,'visible',visibility);
    end
    
    function set_tl_view(self,tl_view_new)
      tl=self.model.tl;
      t0=tl(1);
      tf=tl(2);
      T=tf-t0;
      T_window=diff(tl_view_new);
      slider_step_major=T_window/(T-T_window);  
        % convert the fraction of the trough occupied by the slider to Matlab's
        % SliderStep property, which I find strange and confusing
      t_window=mean(tl_view_new);  % the time at the middle of the view limits
      if T_window==T
        slider_value=0.5;
      else
        slider_value=(t_window-t0-(T_window/2))/(T-T_window);
        slider_value=max(0,min(slider_value,1));  % in case of round-off error
      end  
      if isfinite(slider_step_major)  
        slider_step=slider_step_major*[0.1 1];
        enablement='on';
      else
        slider_step=[0.01 slider_step_major];  
          % minor step doesn't matter in this case, and Matlab throws an error if
          % it's inf
        enablement='off';
      end
      set(self.scrollbar_h, ...
            'sliderstep',slider_step, ...
            'value',slider_value, ...
            'enable',enablement);
    end
    
    function set_position(self,pos)
      set(self.scrollbar_h,'position',pos);    
    end
    
    function something_manipulated_you(self)
      tl=self.model.tl;
      t0=tl(1);
      tf=tl(2);
      T=tf-t0;
      slider_value=get(self.scrollbar_h,'value');
      T_window=diff(self.view.tl_view);
      t_window=slider_value*(T-T_window)+T_window/2+t0;
      tl_view_new=t_window+T_window/2*[-1 +1];
      self.view.set_tl_view(tl_view_new);
        % this will lead to self.time_limits_changed() being called,
        % which hopefully won't cause jittery behavior
    end
  end  % methods

  methods (Access=private)
  end  % methods
  
end  % classdef
