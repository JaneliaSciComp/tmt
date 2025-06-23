classdef Power_spectrum < handle
% This is a class to represent a window showing a power spectrum in
% groundswell.  It is controller, model, and view all rolled into one.
  
properties
  % HG handles
  fig;
  plot;
  line;
%   line_ci1;
%   line_ci2;
  patches_eb;
  xlabel;
  ylabel;
  title;

  menu_y_axis;
  item_y_power;
  item_y_amplitude;
  item_y_linear;
  item_y_log10;
  item_y_db;
  item_y_raw;
  item_y_unit_area;
  item_y_wn_unit;
  
  menu_x_axis;
  item_x_linear;
  item_x_log10;

  % model stuff
  f;
  S_log;
  S_log_ci;
  name;
  units;
  fs;
  f_max_keep;
  W_smear_fw;
  N_fft;
  mode_pa='power';  % power, amplitude
  mode_ll='linear';  % linear, log10, decibels
  mode_rn='raw';  % raw, unit_area (==Z-scored), WN is unity
  mode_ll_x='linear';  % x-axis scale: linear, log10
end  % properties

methods
  function self=Power_spectrum(f,S_log,S_log_ci,name,units, ...
                               fs,f_max_keep,W_smear_fw,N_fft)
    % define colors
    %blue=[0 0 1];
    %light_blue=[0.8 0.8 1];

    % make HG objects
    self.fig=figure('name',sprintf('Spectrum of %s',name), ...
                    'color','w');
    self.plot=axes('parent',self.fig,...
                   'layer','top',...
                   'box','on');
%     self.line_ci1=line('parent',self.plot,...
%                        'xdata',[],...
%                        'ydata',[],...
%                        'color',light_blue);  %#ok
%     self.line_ci2=line('parent',self.plot,...
%                        'xdata',[],...
%                        'ydata',[],...
%                        'color',light_blue);  %#ok
    self.patches_eb=[];                 
    self.line=line('parent',self.plot,...
                   'xdata',[],...
                   'ydata',[],...
                   'color','k');  %#ok
    self.ylabel=ylabel(self.plot,'');  %#ok
    self.xlabel=xlabel(self.plot,'');  %#ok
    self.title=title(self.plot,...
                     sprintf('Spectrum of %s',name), ...
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
    self.item_y_power= ...
      uimenu(self.menu_y_axis, ...
             'label','Power', ...
             'Callback',@(~,~)(self.set_mode_pa('power')));
    self.item_y_amplitude= ...
      uimenu(self.menu_y_axis, ...
             'label','Amplitude', ...
             'Callback',@(~,~)(self.set_mode_pa('amplitude')));
    self.item_y_linear= ...
      uimenu(self.menu_y_axis, ...
             'label','Linear', ...
             'separator','on', ...
             'Callback',@(~,~)(self.set_mode_ll('linear')));
    self.item_y_log10= ...
      uimenu(self.menu_y_axis, ...
             'label','Logarithmic', ...
             'Callback',@(~,~)(self.set_mode_ll('log10')));
    self.item_y_db= ...
      uimenu(self.menu_y_axis, ...
             'label','Decibels (dB)', ...
             'Callback',@(~,~)(self.set_mode_ll('db')));
    self.item_y_raw= ...
      uimenu(self.menu_y_axis, ...
             'label','Raw', ...
             'separator','on', ...
             'Callback',@(~,~)(self.set_mode_rn('raw')));
    self.item_y_unit_area= ...
      uimenu(self.menu_y_axis, ...
             'label','Area under power density is one', ...
             'Callback',@(~,~)(self.set_mode_rn('unit_area')));
    self.item_y_wn_unit= ...
      uimenu(self.menu_y_axis, ...
             'label','White noise implies unit density', ...
             'Callback',@(~,~)(self.set_mode_rn('wn_unity')));

    % store stuff
    self.f=f;
    self.S_log=S_log;
    self.S_log_ci=S_log_ci;
    self.name=name;
    self.units=units;
    self.fs=fs;
    self.f_max_keep=f_max_keep;
    self.W_smear_fw=W_smear_fw;
    self.N_fft=N_fft;
     
    % initial sync of the figure
    self.sync_view()
  end  % constructor  

  function set.mode_pa(self,mode_new)
    self.mode_pa=mode_new;
    self.sync_view();    
  end

  function set.mode_ll(self,mode_new)
    self.mode_ll=mode_new;
    self.sync_view();    
  end

  function set.mode_rn(self,mode_new)
    self.mode_rn=mode_new;
    self.sync_view();    
  end

  function set.mode_ll_x(self,mode_new)
    self.mode_ll_x=mode_new;
    self.sync_view();    
  end

  % this exists only because "self.set_mode_pa(whatever)" can be used
  % inside an anon function, but "self.mode_pa=whatever" can't
  function set_mode_pa(self,mode_new)
    self.mode_pa=mode_new;
  end

  function set_mode_ll(self,mode_new)
    self.mode_ll=mode_new;
  end

  function set_mode_rn(self,mode_new)
    self.mode_rn=mode_new;
  end

  function set_mode_ll_x(self,mode_new)
    self.mode_ll_x=mode_new;
  end

  function sync_view(self)
    % calculate y, y CI
    f=self.f;
    y=self.S_log;
    y_ci=self.S_log_ci;
    if ~strcmp(self.mode_rn,'raw')
      df=(f(end)-f(1))/(length(f)-1);
      S=10.^(self.S_log);  % S_log is log base 10 now
      S_int=df*sum(S);
      if strcmp(self.mode_rn,'unit_area')
        % unit_area, i.e. Z-scored, i.e. unit area under curve
        offset=-log10(S_int);
          % adding this in log-space == dividing by S_int
      else
        % white noise is unity, means area under curve is fs/2
        offset=log10(self.fs/2)-log10(S_int);
      end        
      y=y+offset;
      y_ci=y_ci+offset;
    end
    if strcmp(self.mode_pa,'amplitude')
      y=0.5*y;
      y_ci=0.5*y_ci;
    end
    if strcmp(self.mode_ll,'linear') || strcmp(self.mode_ll,'log10')
      y=10.^(y);
      y_ci=10.^(y_ci);
    %elseif strcmp(self.mode_ll,'log10')
    %  % convert nat log to log10
    %  y=y./log(10);
    %  y_ci=y_ci./log(10);
    elseif strcmp(self.mode_ll,'db')
      % convert log10 to dB
      y=10*y;
      y_ci=10*y_ci;
    end

    % if the x-axis will be a log axis, need to get rid of the f==0 point,
    % since that will break the patches.
    if strcmp(self.mode_ll_x,'log10')
      f=f(2:end);
      y=y(2:end);
      y_ci=y_ci(2:end,:);
    end
    
    % figure out y axis limits
    switch self.mode_ll
      case 'linear'
        y_max=max(max(y),max(max(y_ci)));
        if isfinite(y_max)
          yl=[0 1.05*y_max];
        else
          yl=[0 1];
        end          
      case 'log10'
        y_max=max(max(log10(y)),max(max(log10(y_ci))));
        y_min=min(min(log10(y)),min(min(log10(y_ci))));
        y_mid=(y_max+y_min)/2;
        y_radius=(y_max-y_min)/2;
        yl=y_mid+1.05*y_radius*[-1 +1];
        yl=10.^yl;
        if any(~isfinite(yl))
          yl=[0.1 10];
        end
      case 'db'
        y_max=max(max(y),max(max(y_ci)));
        y_min=min(min(y),min(min(y_ci)));
        y_mid=(y_max+y_min)/2;
        y_radius=(y_max-y_min)/2;
        yl=y_mid+1.05*y_radius*[-1 +1];
        if any(~isfinite(yl))
          yl=[-10 10];
        end
    end

    % figure out x axis limits
    switch self.mode_ll_x
      case 'linear'
        xl=[0 self.f_max_keep];
      otherwise
        xl=[self.W_smear_fw/2 self.f_max_keep];
    end
    
    % build the units string for the spectrum
    units=self.units;
    if isempty(units)
      units_str='?';
    else
      units_str=units;
    end
    if strcmp(self.mode_rn,'wn_unity')
      units_str='pure';
    else
      if strcmp(self.mode_rn,'unit_area')
        units_str='1';
      else
        % raw
        if strcmp(self.mode_pa,'power')
          units_str=[units_str '^2'];
        end
      end
      units_str=[units_str '/Hz'];
      if strcmp(self.mode_pa,'amplitude')
        units_str=[units_str '^{0.5}'];
      end
    end
    if strcmp(self.mode_ll,'db')
      units_str=[units_str ', dB'];
    end
    
    % build y-axis label
    if strcmp(self.mode_pa,'power')
      y_str=sprintf('Power density (%s)',units_str);
    elseif strcmp(self.mode_pa,'amplitude')
      y_str=sprintf('Amplitude density (%s)',units_str);
    end
    %if strcmp(self.mode_pa,'power') && ~strcmp(self.mode_ll,'log10')
    %  y_str=sprintf('Power density (%s)',units_str);
    %elseif strcmp(self.mode_pa,'amplitude') && ~strcmp(self.mode_ll,'log10')
    %  y_str=sprintf('Amplitude density (%s)',units_str);
    %elseif strcmp(self.mode_pa,'power') && strcmp(self.mode_ll,'log10')
    %  y_str=sprintf('log_{10} power density (%s)',units_str);
    %elseif strcmp(self.mode_pa,'amplitude') && strcmp(self.mode_ll,'log10')
    %  y_str=sprintf('log_{10} amplitude density (%s)',units_str);
    %end
    
    % set the y-axis scale
    if strcmp(self.mode_ll,'linear') || strcmp(self.mode_ll,'db')
      set(self.plot,'yscale','linear');
    elseif strcmp(self.mode_ll,'log10')
      set(self.plot,'yscale','log');
    end

    % set the x-axis scale
    if strcmp(self.mode_ll_x,'linear')
      set(self.plot,'xscale','linear');
    elseif strcmp(self.mode_ll_x,'log10')
      set(self.plot,'xscale','log');
    end

    % build x-axis label
    switch self.mode_ll_x
      case 'linear'
        x_str='Frequency (Hz)';
      otherwise
        x_str='Frequency (Hz)';
    end
    
    % sync each plot object
    set(self.line,'xdata',f,'ydata',y,'zdata',repmat(2,size(f)));
    %set(self.line_ci1,'xdata',f,'ydata',y_ci(:,1));
    %set(self.line_ci2,'xdata',f,'ydata',y_ci(:,2));
    delete(self.patches_eb);
    self.patches_eb=patch_eb(f,...
                             y_ci,...
                             [0.75 0.75 0.75],...
                             'EdgeColor','none');
    set(self.plot,'xlim',xl);
    set(self.plot,'ylim',yl);
    set(self.ylabel,'string',y_str);
    set(self.xlabel,'string',x_str);
    
    % sync the checkboxes to the model mode variables
    switch self.mode_pa
      case 'power'
        set(self.item_y_power,'checked','on');
        set(self.item_y_amplitude,'checked','off');
      case 'amplitude'
        set(self.item_y_power,'checked','off');
        set(self.item_y_amplitude,'checked','on');
    end
    switch self.mode_ll
      case 'linear'
        set(self.item_y_linear,'checked','on');
        set(self.item_y_log10,'checked','off');
        set(self.item_y_db,'checked','off');
      case 'log10'
        set(self.item_y_linear,'checked','off');
        set(self.item_y_log10,'checked','on');
        set(self.item_y_db,'checked','off');
      case 'db'
        set(self.item_y_linear,'checked','off');
        set(self.item_y_log10,'checked','off');
        set(self.item_y_db,'checked','on');
    end
    switch self.mode_rn
      case 'raw'
        set(self.item_y_raw,'checked','on');
        set(self.item_y_unit_area,'checked','off');
        set(self.item_y_wn_unit,'checked','off');
      case 'unit_area'
        set(self.item_y_raw,'checked','off');
        set(self.item_y_unit_area,'checked','on');
        set(self.item_y_wn_unit,'checked','off');
      case 'wn_unity'
        set(self.item_y_raw,'checked','off');
        set(self.item_y_unit_area,'checked','off');
        set(self.item_y_wn_unit,'checked','on');
    end
    switch self.mode_ll_x
      case 'linear'
        set(self.item_x_linear,'checked','on');
        set(self.item_x_log10,'checked','off');
      case 'log10'
        set(self.item_x_linear,'checked','off');
        set(self.item_x_log10,'checked','on');
    end
    
  end
  
end  % methods
    
end  % classdef
