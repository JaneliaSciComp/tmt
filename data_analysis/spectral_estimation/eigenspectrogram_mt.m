function [f, t, ...
          V_mag, V_phase, lambda, ...
          V_mag_ci, V_phase_ci, lambda_ci, ...
          N_fft, f_res_diam, K] = ...
  eigenspectrogram_mt(dt, x, ...
                      T_window_want, dt_window_want, ...
                      NW, K_want, F, ...
                      p_FFT_extra, conf_level)

% dt a scalar
% x is N_total x M, N_total the number of time points, M the number of signals

% On return:        
%   f is of shape [N_f 1]
%   t is of shape [n_windows 1]
%   V_mag is of shape [N_f M M n_windows], 2nd dim indexes signals, 3rd dim
%     indexes evecs
%   V_phase is of shape [N_f M M n_windows], 2nd dim indexes signals, 3rd dim
%     indexes evecs
%   lambda is of shape [N_f M n_windows]
%   V_mag_ci is of shape [N_f M M 2 n_windows]
%   V_phase_ci is of shape [N_f M M 2 n_windows]
%   lambda_ci is of shape [N_f M 2 n_windows]

% deal with args
if ~exist('p_FFT_extra', 'var') || isempty(p_FFT_extra)
  p_FFT_extra=2;
end
if ~exist('conf_level', 'var') || isempty(conf_level)
  conf_level=0;
end

% get dimensions
N_total = size(x,1) ;
M = size(x,2) ;

% convert window size from time to elements 
N_window=round(T_window_want/dt);  % number of samples per window
di_window=round(dt_window_want/dt);
n_windows=floor((N_total-N_window)/di_window+1);  
  % n_windows is number of windows that will fit

% % calculate realized T_window, dt_window
% T_window=dt*N_window;
% dt_window=dt*di_window;

% truncate data so we have integer number of windows
N_total=(n_windows-1)*di_window+N_window;
x=x(1:N_total,:);

% alloc the time base (these are the centers of each window)
i_t=zeros(n_windows,1);

% do it
for j=1:n_windows
  i_start=(j-1)*di_window+1;
  i_end=i_start+N_window-1;
  i_t(j)=(i_start+i_end)/2-1;  % want zero-based  
  x_this=x(i_start:i_end,:);
  x_this_mean=mean(x_this,1);
  x_this_cent=x_this-x_this_mean;

  [f,...
   V_mag_this, V_phase_this, lambda_this,...
   N_fft, f_res_diam, K,...
   V_mag_ci_this, V_phase_ci_this, lambda_ci_this]=...
    eigenspectra_mt(dt, x_this_cent, ...
                    NW, K_want, F, ...
                    p_FFT_extra, conf_level) ;
  if j==1
    N_f=length(f);
    V_mag=zeros(N_f,M,M,n_windows);
    V_phase=zeros(N_f,M,M,n_windows);
    lambda=zeros(N_f,M,n_windows);    
    if conf_level>0
      V_mag_ci=zeros(N_f,M,M,2,n_windows);
      V_phase_ci=zeros(N_f,M,M,2,n_windows);
      lambda_ci=zeros(N_f,M,2,n_windows);
    else
      V_mag_ci=[];
      V_phase_ci=[];
      lambda_ci=[];
    end
  end
  V_mag(:,:,:,j)=V_mag_this;
  V_phase(:,:,:,j)=V_phase_this;
  lambda(:,:,j)=lambda_this;
  if conf_level>0
    V_mag_ci(:,:,:,:,j)=V_mag_ci_this;
    V_phase_ci(:,:,:,:,j)=V_phase_ci_this;
    lambda_ci(:,:,:,j)=lambda_ci_this;
  end
end
t=dt*i_t;
