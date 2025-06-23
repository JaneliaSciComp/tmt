function transfer_function(gsmc)

% get stuff we'll need
groundswell_figure_h=gsmc.view.fig_h;
i_selected=gsmc.view.i_selected;
t=gsmc.model.t;
data=gsmc.model.data;
names=gsmc.model.names;

% are there exactly two signals selected?
n_selected=length(i_selected);
if n_selected~=2
  errordlg('Can only calculate transfer function between two signals at a time.',...
           'Error');
  return;
end

% get indices of signals
i_y=i_selected(1);  % the non-pivot is the output/test signal
i_x=i_selected(2);  % the pivot is the input/reference signal

% extract the data we need
n_t=length(t);
n_sweeps=size(data,3);
x=reshape(data(:,i_x,:),[n_t n_sweeps]);
name_x=names{i_x};
%units_x=units{i_x};
y=reshape(data(:,i_y,:),[n_t n_sweeps]);
name_y=names{i_y};
%units_y=units{i_y};
clear data;

% calc sampling rate
dt=(t(end)-t(1))/(length(t)-1);
fs=1/dt;

% throw up the dialog box
param_str=inputdlg({ 'Number of windows:' , ...
                     'Time-bandwidth product (NW):' , ...
                     'Number of tapers:' , ...
                     'Maximum frequency (Hz):' ,...
                     'Extra FFT powers of 2:' , ...
                     'Confidence level:' },...
                     'Transfer function parameters...',...
                   1,...
                   { '1' , ...
                     '4' , ...
                     '7' , ...
                     sprintf('%0.3f',fs/2) , ...
                     '2' , ...
                     '0.95' },...
                   'off');
if isempty(param_str)
  return;
end

% break out the returned cell array
n_windows_str=param_str{1};
NW_str=param_str{2};
K_str=param_str{3};
f_max_keep_str=param_str{4};
p_FFT_extra_str=param_str{5};
conf_level_str=param_str{6};

%
% convert strings to numbers, and do sanity checks
%

% n_windows
n_windows=str2double(n_windows_str);
if isempty(n_windows)
  errordlg('Number of windows not valid','Error');
  return;
end
if n_windows~=round(n_windows)
  errordlg('Number of windows must be an integer','Error');
  return;
end
if n_windows<1
  errordlg('Number of windows must be >= 1','Error');
  return;
end

% NW
NW=str2double(NW_str);
if isempty(NW)
  errordlg('Time-bandwidth product (NW) not valid','Error');
  return;
end
if NW<1
  errordlg('Time-bandwidth product (NW) must be >= 1','Error');
  return;
end

% K
K=str2double(K_str);
if isempty(K)
  errordlg('Number of tapers not valid','Error');
  return;
end
if K~=round(K)
  errordlg('Number of tapers must be an integer','Error');
  return;
end
if K>2*NW-1
  errordlg('Number of tapers must be <= 2*NW-1','Error');
  return;
end

% f_max_keep
f_max_keep=str2double(f_max_keep_str);
if isempty(f_max_keep)
  errordlg('Maximum frequency not valid','Error');
  return;
end
if f_max_keep<0
  errordlg('Maximum frequency must be >= 0','Error');
  return;
end
if f_max_keep>fs/2
  errordlg(sprintf(['Maximum frequency must be <= half the ' ...
                    'sampling frequency (%0.3f Hz)'],fs),...
           'Error');
  return;
end

% p_FFT_extra
p_FFT_extra=str2double(p_FFT_extra_str);
if isempty(p_FFT_extra)
  errordlg('Extra FFT powers of 2 not valid','Error');
  return;
end
if p_FFT_extra~=round(p_FFT_extra)
  errordlg('Extra FFT powers of 2 must be an integer','Error');
  return;
end
if p_FFT_extra<0
  errordlg('Extra FFT powers of 2 must be >= 0','Error');
  return;
end

% conf_level
conf_level=str2double(conf_level_str);
if isempty(conf_level)
  errordlg('Confidence level not valid','Error');
  return;
end
if conf_level<0
  errordlg('Confidence level must be >= 0','Error');
  return;
end
if conf_level>=1
  errordlg('Confidence level must be < 1',...
           'Error');
  return;
end

%
% all parameters are converted, and are in-bounds
%



%
% do the analysis
%

% may take a while
set(groundswell_figure_h,'pointer','watch');
drawnow('update');
drawnow('expose');

% % to test
% data(:,1)=cos(2*pi*1*t);

% get just the data in view
tl_view=gsmc.view.tl_view;
N=length(t);
jl=interp1([t(1) t(end)],[1 N],tl_view,'linear','extrap');
jl(1)=floor(jl(1));
jl(2)= ceil(jl(2));
jl(1)=max(1,jl(1));
jl(2)=min(N,jl(2));
x_short=x(jl(1):jl(2),:);
y_short=y(jl(1):jl(2),:);
clear t x y;
N=size(x_short,1);

% center the data
x_short_mean=mean(x_short,1);
x_short_cent=x_short-repmat(x_short_mean,[N 1]);
y_short_mean=mean(y_short,1);
y_short_cent=y_short-repmat(y_short_mean,[N 1]);

% determine window size
N_window=floor(N/n_windows);
%T_window=dt*N_window;

% want N to be integer multiple of N_window
N=N_window*n_windows;
x_short_cent=x_short_cent(1:N,:);
y_short_cent=y_short_cent(1:N,:);
%T=dt*N;

% put windows into the second index
x_short_cent_windowed=...
  reshape(x_short_cent,[N_window n_windows*n_sweeps]);
y_short_cent_windowed=...
  reshape(y_short_cent,[N_window n_windows*n_sweeps]);

% calc the coherency, using multitaper routine
[f,Hyx_mag,Hyx_phase,...
 N_fft,W_smear_fw,~,...
 Hyx_mag_ci,Hyx_phase_ci]=...
  tf_mt(dt,y_short_cent_windowed,x_short_cent_windowed,...
        NW,K,f_max_keep,...
        p_FFT_extra,conf_level);
n_f=length(f);

% % calc the significance threshold, quick
% R=n_windows*n_sweeps;  % number of samples of each process
% %alpha_thresh=0.05;
% Hyx_mag_thresh=coh_mt_control_analytical(R,K,alpha_thresh);

% plot TF
f_lim=[0 f_max_keep];
Hyx_mag_lim=[];
Hyx_phase_lim=[];
title_str=sprintf('Transfer function of %s from %s',name_y,name_x);
[h_fig_tf,...
 h_mag_axes,h_phase_axes,...
 h_mag,h_phase,...
 h_mag_ci,h_phase_ci]=...
  figure_tf(f,Hyx_mag,Hyx_phase,...
            Hyx_mag_ci,Hyx_phase_ci,...
            f_lim,Hyx_mag_lim,Hyx_phase_lim,...
            title_str);
set(h_fig_tf,'color','w');          
fig_border_label=sprintf('Transfer function of %s from %s',name_y,name_x);
set(h_fig_tf,'name',fig_border_label);
set(get(h_mag_axes  ,'ylabel'),'String','Magnitude');
set(get(h_phase_axes,'ylabel'),'String','Phase (deg)');
text(1,1.01,sprintf('W_smear_fw: %0.3f Hz\nN_fft: %d',W_smear_fw,N_fft),...
     'parent',h_mag_axes,...
     'units','normalized',...
     'horizontalalignment','right',...
     'verticalalignment','bottom',...
     'interpreter','none');
drawnow('update');
drawnow('expose');

% set pointer back
set(groundswell_figure_h,'pointer','arrow');
drawnow('update');
drawnow('expose');
