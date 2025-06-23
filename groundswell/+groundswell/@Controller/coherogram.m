function coherogram(gsmc)

% get the figure handle
groundswell_figure_h=gsmc.view.fig_h;

% get stuff we'll need
i_selected=gsmc.view.i_selected;
t=gsmc.model.t;
data=gsmc.model.data;
names=gsmc.model.names;
n_sweeps=size(data,3);
tl_view=gsmc.view.tl_view;

% are there exactly two signals selected?
n_selected=length(i_selected);
if n_selected~=2
  errordlg('Can only calculate coherency between two signals at a time.',...
           'Error');
  return;
end

% check number of sweeps
if isempty(n_sweeps) || n_sweeps~=1
  errordlg('Must have exactly one sweep to calculate coherogram.',...
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

% throw up the dialog box, check params
params=groundswell.get_coherogram_params(tl_view,dt);

% check for error exit
if isempty(params)
  return;
end

% break out params
T_window_want=params.T_window_want;
n_steps_per_window_want=params.n_steps_per_window_want;
NW=params.NW;
K=params.K;
f_max_keep=params.f_max_keep;
p_FFT_extra=params.p_FFT_extra;
alpha_thresh=params.alpha_thresh;


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
N=length(t);
jl=interp1([t(1) t(end)],[1 N],tl_view,'linear','extrap');
jl(1)=floor(jl(1));
jl(2)= ceil(jl(2));
jl(1)=max(1,jl(1));
jl(2)=min(N,jl(2));
t_short=t(jl(1):jl(2));
x_short=x(jl(1):jl(2),:);
y_short=y(jl(1):jl(2),:);
clear t x y N;
%N=size(x_short,1);

% determine desired window step size
dt_window_want=T_window_want/n_steps_per_window_want;

% check T_window_want, dt_window want before calling powgram_mt
% this part relies on knowing how powgram_mt determines
% N_window and di_window given T_window_want, dt_window_want, and dt
% not a very elegant way of doing things, but the alternative was an
% extended orgy of refactoring (but like a bad orgy)
N_window=round(T_window_want/dt);  % number of samples per window
di_window=round(dt_window_want/dt);
if N_window<=1
  set(groundswell_figure_h,'pointer','arrow'); 
  drawnow('update');
  drawnow('expose');
  errordlg(['The requested window duration (and the sampling rate of ' ...
            'the data) will result in one or fewer spectrogram windows.'],...
           'Error');
  return;
end
if di_window<1
  set(groundswell_figure_h,'pointer','arrow');
  drawnow('update');
  drawnow('expose');
  errordlg(['The requested window duration and number of steps per ' ...
            'window (and the sampling rate of ' ...
            'the data) will result in a step size of less than one ' ...
            'sample between spectrogram windows.'],...
           'Error');
  return;
end
if ~(2*NW<N_window)
  set(groundswell_figure_h,'pointer','arrow');
  drawnow('update');
  drawnow('expose');
  errordlg(['The requested window duration (and the sampling rate of ' ...
            'the data) results in a window size less than or equal to ' ...
            '2*NW.'],...
           'Error');
  return;
end

% calc the coherency, using multitaper routine
conf_level=0;
[f,t,...
 Cyx_mag,Cyx_phase,...
 ~,~,...
 N_fft,W_smear_fw]=...
  cohgram_mt(dt,y_short,x_short,...
             T_window_want,dt_window_want,...
             NW,K,f_max_keep,...
             p_FFT_extra,conf_level);
%n_f=length(f);
t=t+t_short(1);  % cohgram_mt only knows dt, so have to do this           

% calc the significance threshold, quick
R=1;  % number of samples of each process per window
%alpha_thresh=0.05;
Cyx_mag_thresh=coh_mt_control_analytical(R,K,alpha_thresh);

% plot a better "colorbar"---do this first, so it's on the bottom
fig_name_str=...
  sprintf('Color wheel for coherogram of %s relative to %s',name_y,name_x);
figure('name',fig_name_str,'color','w');
plot_coh2l75_border_legend(Cyx_mag_thresh);
drawnow('update');
drawnow('expose');

% plot coherogram
title_str=sprintf('Coherogram of %s relative to %s',name_y,name_x);
[h,h_a]=...
  figure_cohgram(t,f,Cyx_mag,Cyx_phase,...
                 tl_view,[0 f_max_keep],...
                 title_str,...
                 Cyx_mag_thresh);
set(h,'name',title_str);
set(h,'color','w');
text('parent',h_a, ...
     'position',[1 1.005], ...
     'string', ...
       sprintf('W_smear_fw: %0.3f Hz',W_smear_fw), ...
               'units','normalized', ...
               'horizontalalignment','right', ...
               'verticalalignment','bottom', ...
               'interpreter','none');
text('parent',h_a, ...
     'position',[0 1.005], ...
     'string', ...
       sprintf('N_fft: %d',N_fft), ...
               'units','normalized', ...
               'horizontalalignment','left', ...
               'verticalalignment','bottom', ...
               'interpreter','none');
drawnow('update');
drawnow('expose');

% set pointer back
set(groundswell_figure_h,'pointer','arrow');
drawnow('update');
drawnow('expose');
