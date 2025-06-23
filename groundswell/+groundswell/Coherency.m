classdef Coherency < handle
% This is a class to represent a window showing a coherency plot in
% groundswell.  It is controller, model, and view all rolled into one.
  
properties
  % HG handles
  fig;
  title;

  plot_top;
  line_top;
  patches_top_eb;
  ylabel_top;
  line_thresh;
  
  plot_bottom;
  lines_bottom;
  patches_bottom_eb;
  ylabel_bottom;

  xlabel;

  menu_y_axis;
  item_y_linear;
  item_y_atanh;
  
  menu_x_axis;
  item_x_linear;
  item_x_log10;

  % model stuff
  f;
  Cyx_mag_atanh
  Cyx_mag_atanh_ci
  Cyx_mag_atanh_thresh
  Cyx_phase
  Cyx_phase_ci
  name_y;
  name_x;
  %units_y;
  %units_x;
  fs;
  f_max_keep;
  W_smear_fw;
  N_fft;
  mode_ll='linear';  % linear, atanh
  mode_ll_x='linear';  % x-axis scale: linear, log10
end  % properties

methods
  function self=Coherency(f, ...
                          Cyx_mag_atanh,Cyx_phase, ...
                          Cyx_mag_atanh_ci,Cyx_phase_ci, ...
                          Cyx_mag_atanh_thresh, ...
                          name_y,name_x, ...
                          fs,f_max_keep,W_smear_fw,N_fft)
    % make HG objects
    title_str=sprintf('Coherency of %s relative to %s',name_y,name_x);
    self.fig=figure('name',title_str, ...
                    'color','w');
    
    %h_plot=0.341;
    h_plot=0.39;    
    self.plot_top=axes('parent',self.fig,...
                       'layer','top',...
                       'box','on', ...
                       'xticklabel',{}, ...
                       'position',[0.130 0.925-h_plot 0.775 h_plot]);
    self.line_top=line('parent',self.plot_top,...
                       'xdata',[],...
                       'ydata',[],...
                       'zdata',[],...
                       'color','k');
    self.line_thresh=line('parent',self.plot_top,...
                          'xdata',[],...
                          'ydata',[],...
                          'zdata',[],...
                          'linestyle','--', ...
                          'color','k');
    self.patches_top_eb=[];                 
    self.ylabel_top=ylabel(self.plot_top,'');
    self.title=title(self.plot_top,...
                     title_str, ...
                     'interpreter','none');  %#ok
    text(1,1.005, ...
         sprintf('W_smear_fw: %0.3f Hz',W_smear_fw), ...
                 'units','normalized', ...
                 'horizontalalignment','right', ...
                 'verticalalignment','bottom', ...
                 'interpreter','none');
    text(0,1.005, ...
         sprintf('N_fft: %d',N_fft), ...
                 'units','normalized', ...
                 'horizontalalignment','left', ...
                 'verticalalignment','bottom', ...
                 'interpreter','none');

    self.plot_bottom=axes('parent',self.fig,...
                         'layer','top',...
                         'box','on', ...
                         'position',[0.130 0.110 0.775 h_plot]);
    self.lines_bottom=[];
    self.patches_bottom_eb=[];                 
    self.ylabel_bottom=ylabel(self.plot_bottom,'');
    self.xlabel=xlabel(self.plot_bottom,'');  %#ok
               
    % add X axis menu
    self.menu_x_axis=uimenu(self.fig,'label','X axis');
    self.item_x_linear= ...
      uimenu(self.menu_x_axis, ...
             'label','Linear', ...
             'Callback',@(~,~)(self.set_mode_ll_x('linear')));
    self.item_x_log10= ...
      uimenu(self.menu_x_axis, ...
             'label','Logarithmic', ...
             'Callback',@(~,~)(self.set_mode_ll_x('log10')));
           
    % add Y axis menu
    self.menu_y_axis=uimenu(self.fig,'label','Y axis');
    self.item_y_linear= ...
      uimenu(self.menu_y_axis, ...
             'label','Linear', ...
             'Callback',@(~,~)(self.set_mode_ll('linear')));
    self.item_y_atanh= ...
      uimenu(self.menu_y_axis, ...
             'label','Atanh', ...
             'Callback',@(~,~)(self.set_mode_ll('atanh')));

    % store stuff
    self.f=f;
    self.Cyx_mag_atanh=Cyx_mag_atanh;
    self.Cyx_mag_atanh_ci=Cyx_mag_atanh_ci;
    self.Cyx_mag_atanh_thresh=Cyx_mag_atanh_thresh;
    self.Cyx_phase=Cyx_phase;
    self.Cyx_phase_ci=Cyx_phase_ci;
    self.name_y=name_y;
    self.name_x=name_x;
    %self.units_y=units_y;
    %self.units_x=units_x;    
    self.fs=fs;
    self.f_max_keep=f_max_keep;
    self.W_smear_fw=W_smear_fw;
    self.N_fft=N_fft;
     
    % initial sync of the figure
    self.sync_view()
  end  % constructor  

  function set.mode_ll(self,mode_new)
    self.mode_ll=mode_new;
    self.sync_view();    
  end

  function set.mode_ll_x(self,mode_new)
    self.mode_ll_x=mode_new;
    self.sync_view();    
  end

  % this exists only because "self.set_mode_pa(whatever)" can be used
  % inside an anon function, but "self.mode_pa=whatever" can't
  function set_mode_ll(self,mode_new)
    self.mode_ll=mode_new;
  end

  function set_mode_ll_x(self,mode_new)
    self.mode_ll_x=mode_new;
  end

  function sync_view(self)
    % calculate y_top, y_top CI
    f=self.f;
    y_top=self.Cyx_mag_atanh;
    y_top_ci=self.Cyx_mag_atanh_ci;
    y_thresh=self.Cyx_mag_atanh_thresh;
    if strcmp(self.mode_ll,'linear')
      y_top=tanh(y_top);
      y_top_ci=tanh(y_top_ci);
      y_thresh=tanh(y_thresh);
    end

    % calculate y_bottom
    y_bottom=self.Cyx_phase;
    y_bottom=180/pi*y_bottom;
    y_bottom_ci=self.Cyx_phase_ci;
    y_bottom_ci=180/pi*y_bottom_ci;    
    
    % if the x-axis will be a log axis, need to get rid of the f==0 point,
    % since that will break the patches.
    if strcmp(self.mode_ll_x,'log10')
      f=f(2:end);
      y_top=y_top(2:end);
      y_top_ci=y_top_ci(2:end,:);
      y_bottom=y_bottom(2:end);
      y_bottom_ci=y_bottom_ci(2:end,:);
    end
    
    % figure out y_top axis limits
    switch self.mode_ll
      case 'linear'
        y_top_limits=[0 1.05];
      case 'atanh'
        y_top_max=max(max(y_top),max(max(y_top_ci)));
        y_top_limits=[0 1.05*y_top_max];
    end

    % figure out y_bottom axis limits
    y_bottom_limits=[-180 +180];

    % figure out the bottom y-axis tick locations
    y_bottom_ticks=(-180:90:+180)';
    
    % figure out x axis limits
    switch self.mode_ll_x
      case 'linear'
        x_limits=[0 self.f_max_keep];
      otherwise
        x_limits=[self.W_smear_fw/2 self.f_max_keep];
    end
        
    % build top y-axis label
    switch self.mode_ll
      case 'linear'
        y_top_str='Magnitude';
      case 'atanh'
        y_top_str='Atanh-magnitude';
    end
    
    % build phase y-axis label
    y_bottom_str='Phase (deg)';
    
    % set the x-axis scale
    if strcmp(self.mode_ll_x,'linear')
      set(self.plot_top,'xscale','linear');
      set(self.plot_bottom,'xscale','linear');
    elseif strcmp(self.mode_ll_x,'log10')
      set(self.plot_top,'xscale','log');
      set(self.plot_bottom,'xscale','log');
    end

    % build x-axis label
    x_str='Frequency (Hz)';
    
    % sync each plot object
    set(self.line_top,'xdata',f,'ydata',y_top,'zdata',repmat(2,size(f)));
    delete(self.patches_top_eb(ishandle(self.patches_top_eb)));
    self.patches_top_eb=patch_eb(f,...
                                 y_top_ci,...
                                 [0.75 0.75 0.75],...
                                 'Parent',self.plot_top, ...
                                 'EdgeColor','none');
    set(self.plot_top,'ylim',y_top_limits);
    set(self.ylabel_top,'string',y_top_str);
    set(self.plot_top,'xlim',x_limits);
    set(self.line_thresh,'xdata',x_limits, ...
                         'ydata',y_thresh*[1 1], ...
                         'zdata',[3 3]);
    
    delete(self.patches_bottom_eb(ishandle(self.patches_bottom_eb)));
    self.patches_bottom_eb=patch_eb_wrap(f, ...
                                         y_bottom, ...
                                         y_bottom_ci, ...
                                         [-180 +180], ...
                                         0.75*[1 1 1], ...
                                         'Parent',self.plot_bottom);
    delete(self.lines_bottom(ishandle(self.lines_bottom)));
    self.lines_bottom=line_wrap(f,y_bottom,...
                                [-180 +180],...
                                'Parent',self.plot_bottom, ...
                                'Color',[0 0 0]);
                                  
    set(self.plot_bottom,'ylim',y_bottom_limits);
    set(self.plot_bottom,'ytick',y_bottom_ticks);
    set(self.ylabel_bottom,'string',y_bottom_str);
    set(self.plot_bottom,'xlim',x_limits);
    set(self.xlabel,'string',x_str);
    
    % sync the checkboxes to the model mode variables
    switch self.mode_ll
      case 'linear'
        set(self.item_y_linear,'checked','on');
        set(self.item_y_atanh,'checked','off');
      case 'atanh'
        set(self.item_y_linear,'checked','off');
        set(self.item_y_atanh,'checked','on');
    end
    switch self.mode_ll_x
      case 'linear'
        set(self.item_x_linear,'checked','on');
        set(self.item_x_log10,'checked','off');
      case 'log10'
        set(self.item_x_linear,'checked','off');
        set(self.item_x_log10,'checked','on');
    end  % switch
    
  end  % method
  
end  % methods
    
end  % classdef
