classdef Spectrogram < handle
% This is a class to represent a window showing a spectrogram in
% groundswell.  It is controller, model, and view all rolled into one.
  
properties
  % HG handles
  fig;
  plot;  % the axes
  im;  % the image that is the spectrogram
  xlabel;
  ylabel;
  title;
  plot_cb;  % the colorbar axes
  im_cb;
  ylabel_cb;

  menu_z_axis;
  item_z_power;
  item_z_amplitude;
  item_z_linear;
  item_z_log10;
  item_z_db;
  item_z_raw;
  item_z_unit_area;
  item_z_wn_unit;
  item_z_blue_to_yellow;
  item_z_jet;
  item_z_hot;
  item_z_gray;
  
  menu_y_axis;
  item_y_linear;
  item_y_log10;
  
  % model stuff
  f;
  t;
  S_log;
  name;
  units;
  fs;
  tl;  % time axis limits
  f_max_keep;
  var_est;  % estimate of variance of original signal
  W_smear_fw;
  N_fft;
  mode_pa='power';  % z-axis: power, amplitude
  mode_ll='linear';  % z-axis: linear, log10, decibels
  mode_rn='raw';  % z-axis: raw, unit_area (==Z-scored), WN is unity
  mode_ll_y='linear';  % y-axis (freq) scale: linear, log10
  cmap_name='blue_to_yellow';
end  % properties

methods
  function self=Spectrogram(t,f,S_log,name,units, ...
                            fs,tl,f_max_keep,var_est, ...
                            W_smear_fw,N_fft)
    % make HG objects
    self.fig=figure('name',sprintf('Spectrogram of %s',name), ...
                    'color','w');
    self.plot=axes('parent',self.fig,...
                   'layer','top',...
                   'box','on');
    self.im=image('parent',self.plot);             
    self.ylabel=ylabel(self.plot,'');  %#ok
    self.xlabel=xlabel(self.plot,'');  %#ok
    self.title=title(self.plot,...
                     sprintf('Spectrogram of %s',name), ...
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
    self.plot_cb=colorbar('peer',self.plot);
    self.im_cb=findobj(self.plot_cb,'type','image');
    self.ylabel_cb=ylabel(self.plot_cb,'');  %#ok
       
    % add Y axis menu
    self.menu_y_axis=uimenu(self.fig,'label','Y axis');
    self.item_y_linear= ...
      uimenu(self.menu_y_axis, ...
             'label','Linear', ...
             'Callback',@(~,~)(self.set_mode_ll_y('linear')));
    self.item_y_log10= ...
      uimenu(self.menu_y_axis, ...
             'label','Logarithmic', ...
             'Callback',@(~,~)(self.set_mode_ll_y('log10')));
           
    % add Z axis menu
    self.menu_z_axis=uimenu(self.fig,'label','Z axis');
    self.item_z_power= ...
      uimenu(self.menu_z_axis, ...
             'label','Power', ...
             'Callback',@(~,~)(self.set_mode_pa('power')));
    self.item_z_amplitude= ...
      uimenu(self.menu_z_axis, ...
             'label','Amplitude', ...
             'Callback',@(~,~)(self.set_mode_pa('amplitude')));
    self.item_z_linear= ...
      uimenu(self.menu_z_axis, ...
             'label','Linear', ...
             'separator','on', ...
             'Callback',@(~,~)(self.set_mode_ll('linear')));
    self.item_z_log10= ...
      uimenu(self.menu_z_axis, ...
             'label','Logarithmic', ...
             'Callback',@(~,~)(self.set_mode_ll('log10')));
    self.item_z_db= ...
      uimenu(self.menu_z_axis, ...
             'label','Decibels (dB)', ...
             'Callback',@(~,~)(self.set_mode_ll('db')));
    self.item_z_raw= ...
      uimenu(self.menu_z_axis, ...
             'label','Raw', ...
             'separator','on', ...
             'Callback',@(~,~)(self.set_mode_rn('raw')));
    self.item_z_unit_area= ...
      uimenu(self.menu_z_axis, ...
             'label','Area under power density is one', ...
             'Callback',@(~,~)(self.set_mode_rn('unit_area')));
    self.item_z_wn_unit= ...
      uimenu(self.menu_z_axis, ...
             'label','White noise implies unit density', ...
             'Callback',@(~,~)(self.set_mode_rn('wn_unity')));
    self.item_z_blue_to_yellow= ...
      uimenu(self.menu_z_axis, ...
             'label','Blue-yellow', ...
             'separator','on', ...
             'Callback',@(~,~)(self.set_cmap_name('blue_to_yellow')));
    self.item_z_jet= ...
      uimenu(self.menu_z_axis, ...
             'label','Jet', ...
             'Callback',@(~,~)(self.set_cmap_name('jet')));
    self.item_z_hot= ...
      uimenu(self.menu_z_axis, ...
             'label','Hot', ...
             'Callback',@(~,~)(self.set_cmap_name('hot')));
    self.item_z_gray= ...
      uimenu(self.menu_z_axis, ...
             'label','Grayscale', ...
             'Callback',@(~,~)(self.set_cmap_name('gray')));

    % store stuff
    self.t=t;
    self.f=f;
    self.S_log=S_log;
    self.name=name;
    self.units=units;
    self.fs=fs;
    self.tl=tl;
    self.var_est=var_est;
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

  function set.mode_ll_y(self,mode_new)
    self.mode_ll_y=mode_new;
    self.sync_view();    
  end

  function set.cmap_name(self,cmap_name_new)
    self.cmap_name=cmap_name_new;
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

  function set_mode_ll_y(self,mode_new)
    self.mode_ll_y=mode_new;
  end

  function set_cmap_name(self,cmap_name_new)
    self.cmap_name=cmap_name_new;
  end

  function sync_view(self)
    % calculate z, z CI
    t=self.t;
    f=self.f;
    z=self.S_log;
    
    % translate the "raw" z (==S_log) to whatever the user says
    % they want to plot
    if ~strcmp(self.mode_rn,'raw')
      if strcmp(self.mode_rn,'unit_area')
        % unit_area, i.e. Z-scored, i.e. unit area under curve
        offset=-log(self.var_est);
          % adding this in log-space == dividing by var_est
      else
        % white noise is unity, means area under one-sided spectrum is fs/2
        offset=log(self.fs/2)-log(self.var_est);
      end        
      z=z+offset;
    end
    if strcmp(self.mode_pa,'amplitude')
      z=0.5*z;
    end
    if strcmp(self.mode_ll,'linear')
      z=exp(z);
    elseif strcmp(self.mode_ll,'log10')
      % convert nat log to log10
      z=z./log(10);
    elseif strcmp(self.mode_ll,'db')
      % convert nat log to log10
      z=10*z./log(10);
    end

    % if freq axis is log-scale, resample z
    if strcmp(self.mode_ll_y,'linear')
      y=f;      
    elseif strcmp(self.mode_ll_y,'log10')      
      df=f(2);
      f_max=f(end);
      dlog10f=log10(f_max/(f_max-df));
      n_line=floor((log10(f_max)-log10(df))/dlog10f)+1;
      log10f=log10(df)+dlog10f*(0:(n_line-1))';
      log10f_un=10.^log10f;
      z=interp1(f,z,log10f_un);
      y=log10f_un;
    end
      
    % figure out z axis limits
    switch self.mode_ll
      case 'linear'
        z_max=max(max(z));
        if isfinite(z_max)
          zl=[0 1.05*z_max];
        else
          zl=[0 1];
        end          
      case 'log10'
        z_max=max(max(z));
        z_min=min(min(z));
        z_mid=(z_max+z_min)/2;
        z_radius=(z_max-z_min)/2;
        zl=z_mid+1.05*z_radius*[-1 +1];
        if any(~isfinite(zl))
          zl=[-1 1];
        end
      case 'db'
        z_max=max(max(z));
        z_min=min(min(z));
        z_mid=(z_max+z_min)/2;
        z_radius=(z_max-z_min)/2;
        zl=z_mid+1.05*z_radius*[-1 +1];
        if any(~isfinite(zl))
          zl=[-10 10];
        end
    end

    % figure out y axis limits
    switch self.mode_ll_y
      case 'linear'
        yl=[0 self.f_max_keep];
      case 'log10'
        yl=[self.W_smear_fw/2 self.f_max_keep];
    end
    
    % figure out x axis limits
    xl=self.tl;
    
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
    
    % build z-axis label
    if strcmp(self.mode_pa,'power')
      z_str=sprintf('Power density (%s)',units_str);
    elseif strcmp(self.mode_pa,'amplitude')
      z_str=sprintf('Amplitude density (%s)',units_str);
    end
    if strcmp(self.mode_ll,'log10')
      z_str=sprintf('log_{10} %s',z_str);
    end

    % build y-axis label
    switch self.mode_ll_y
      case 'linear'
        y_str='Frequency (Hz)';
      otherwise
        y_str='Frequency (Hz)';
        %y_str='log_{10} Frequency (Hz)';
    end
    
    % build x-axis label
    x_str='Time (s)';
    
    % make the colormap
    n_cmap=256;
    cmap=feval(self.cmap_name,n_cmap);
    
    % sync each plot object
    set(self.im,'xdata',[t(1) t(end)], ....
                'ydata',[y(1) y(end)], ...
                'cdata',z, ...
                'cdatamapping','scaled');
    set(self.plot,'xlim',xl);
    set(self.plot,'ylim',yl);
    switch self.mode_ll_y
      case 'linear'
        set(self.plot,'yscale','linear');
      otherwise
        set(self.plot,'yscale','log');
    end
    set(self.plot,'clim',zl);
    set(self.xlabel,'string',x_str);
    set(self.ylabel,'string',y_str);
    set(self.ylabel_cb,'string',z_str);
    set(self.fig,'colormap',cmap);
    
    % sync the checkboxes to the model mode variables
    switch self.mode_pa
      case 'power'
        set(self.item_z_power,'checked','on');
        set(self.item_z_amplitude,'checked','off');
      case 'amplitude'
        set(self.item_z_power,'checked','off');
        set(self.item_z_amplitude,'checked','on');
    end
    switch self.mode_ll
      case 'linear'
        set(self.item_z_linear,'checked','on');
        set(self.item_z_log10,'checked','off');
        set(self.item_z_db,'checked','off');
      case 'log10'
        set(self.item_z_linear,'checked','off');
        set(self.item_z_log10,'checked','on');
        set(self.item_z_db,'checked','off');
      case 'db'
        set(self.item_z_linear,'checked','off');
        set(self.item_z_log10,'checked','off');
        set(self.item_z_db,'checked','on');
    end
    switch self.mode_rn
      case 'raw'
        set(self.item_z_raw,'checked','on');
        set(self.item_z_unit_area,'checked','off');
        set(self.item_z_wn_unit,'checked','off');
      case 'unit_area'
        set(self.item_z_raw,'checked','off');
        set(self.item_z_unit_area,'checked','on');
        set(self.item_z_wn_unit,'checked','off');
      case 'wn_unity'
        set(self.item_z_raw,'checked','off');
        set(self.item_z_unit_area,'checked','off');
        set(self.item_z_wn_unit,'checked','on');
    end
    switch self.mode_ll_y
      case 'linear'
        set(self.item_y_linear,'checked','on');
        set(self.item_y_log10,'checked','off');
      case 'log10'
        set(self.item_y_linear,'checked','off');
        set(self.item_y_log10,'checked','on');
    end
    switch self.cmap_name
      case 'blue_to_yellow'
        set(self.item_z_blue_to_yellow,'checked','on');
        set(self.item_z_jet,'checked','off');
        set(self.item_z_hot,'checked','off');        
        set(self.item_z_gray,'checked','off');
      case 'jet'
        set(self.item_z_blue_to_yellow,'checked','off');
        set(self.item_z_jet,'checked','on');
        set(self.item_z_hot,'checked','off');        
        set(self.item_z_gray,'checked','off');
      case 'hot'
        set(self.item_z_blue_to_yellow,'checked','off');
        set(self.item_z_jet,'checked','off');
        set(self.item_z_hot,'checked','on');        
        set(self.item_z_gray,'checked','off');
      case 'gray'
        set(self.item_z_blue_to_yellow,'checked','off');
        set(self.item_z_jet,'checked','off');
        set(self.item_z_hot,'checked','off');        
        set(self.item_z_gray,'checked','on');        
    end
  end
  
end  % methods
    
end  % classdef
