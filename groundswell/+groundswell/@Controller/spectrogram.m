function spectrogram(self)

% get the figure handle
fig_h=self.view.fig_h;

% get stuff we'll need
selected=self.view.get_selected_axes();
t=self.model.t;
data=self.model.data;
names=self.model.names;
units=self.model.units;
n_sweeps=size(data,3);
tl_view=self.view.tl_view;

% check number of signals selected
n_selected=sum(selected);
if n_selected~=1
  errordlg('Can only calculate spectrogram on one signal at a time.',...
           'Error');
  return;
end

% check number of sweeps
if isempty(n_sweeps) || n_sweeps~=1
  errordlg('Must have exactly one sweep to calculate spectrogram.',...
           'Error');
  return;
end

% get data we care about
data=data(:,selected);
name=names{selected};
units=units{selected};

% calc sampling rate
N=length(t);
dt=(t(end)-t(1))/(N-1);
fs=1/dt;
%T=N*dt;

% throw up the dialog box, check params
params=groundswell.get_spectrogram_params(tl_view,dt);

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


%
% do the analysis
%

% may take a while
set(fig_h,'pointer','watch');
drawnow('update');
drawnow('expose');

% % to test
% data(:,1)=cos(2*pi*1*t);

% get just the data in view
jl=interp1([t(1) t(end)],[1 N],tl_view,'linear','extrap');
jl(1)=floor(jl(1));
jl(2)= ceil(jl(2));
jl(1)=max(1,jl(1));
jl(2)=min(N,jl(2));
t_short=t(jl(1):jl(2));
data_short=data(jl(1):jl(2));
clear t data;
N=length(data_short);
dt=(t_short(end)-t_short(1))/(N-1);

% center the data
data_short_mean=mean(data_short,1);
data_short_cent=data_short-data_short_mean;

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
  set(fig_h,'pointer','arrow');
  drawnow('update');
  drawnow('expose');
  errordlg(['The requested window duration (and the sampling rate of ' ...
            'the data) will result in one or fewer spectrogram windows.'],...
           'Error');
  return;
end
if di_window<1
  set(fig_h,'pointer','arrow');
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
  set(fig_h,'pointer','arrow');
  drawnow('update');
  drawnow('expose');
  errordlg(['The requested window duration (and the sampling rate of ' ...
            'the data) results in a window size less than or equal to ' ...
            '2*NW.'],...
           'Error');
  return;
end 

% calc spectrogram
[f,t,~,S,~,~,N_fft,W_smear_fw]=...
  powgram_mt(dt,data_short_cent,...
             T_window_want,dt_window_want,...
             NW,K,f_max_keep,...
             p_FFT_extra);
t=t+t_short(1);  % powgram_mt only knows dt, so have to do this           
S_log=log(S);  % Spectrogram expects this
var_est=std(data_short_cent)^2;

% % plot spectrogram
% title_str=sprintf('Spectrogram of %s',name);
% [h,h_a]=figure_powgram(t,f,P,...
%                        tl_view,[0 f_max_keep],[],...
%                        'power',[],...
%                        title_str,...
%                        units);
% set(h,'name',title_str);
% set(h,'color','w');
% text('parent',h_a, ...
%      'position',[1 1.005], ...
%      'string', ...
%        sprintf('W_smear_fw: %0.3f Hz',W_smear_fw), ...
%                'units','normalized', ...
%                'horizontalalignment','right', ...
%                'verticalalignment','bottom', ...
%                'interpreter','none');
% text('parent',h_a, ...
%      'position',[0 1.005], ...
%      'string', ...
%        sprintf('N_fft: %d',N_fft), ...
%                'units','normalized', ...
%                'horizontalalignment','left', ...
%                'verticalalignment','bottom', ...
%                'interpreter','none');

% make power spectrum object
groundswell.Spectrogram(t,f,S_log,name,units, ...
                        fs,self.view.tl_view,f_max_keep,var_est, ...
                        W_smear_fw,N_fft);
                         
% set pointer back
set(fig_h,'pointer','arrow');
drawnow('update');
drawnow('expose');
