function [f,...
          V_mag, V_phase, lambda, ...
          N_fft, f_res_diam, K, ...
          V_mag_ci, V_phase_ci, lambda_ci, ...
          lambdas_tao]=...
  eigenspectra_mt(dt,x,...
                  NW,K,W_keep,...
                  p_FFT_extra,conf_level)

% dt a scalar
% x is N x M x R, N the number of time points, M the number of signals, R the
%   number of samples of the process
% On return, Syx is N_f x M x M, N_f the number of freqeuncy samples (which is
%   determined by N, N_fft, and W_keep).  Syx(ifr,i,j) is the cross-power
%   spectrum at frequency sample ifr for signal i and signal j.  Syx(ifr,i,j)
%   is s.t. a positive phase angle means signal i *leads* signal j.
%   reshape(Syx(ifr,:,:), [M M]) is Hermitian for all ifr.

% get the timing info, calc various scalars of interest
N=size(x,1);  %#ok<NASGU>  % number of time points per process sample
M=size(x,2);  % number of signals
R=size(x,3);  % number of samples of the process
fs=1/dt;

% process args
if ~exist('K', 'var') || isempty(K)
  K=2*NW-1;
end
if ~exist('W_keep', 'var')  || isempty(W_keep)
  W_keep=fs/2;
end
if ~exist('p_FFT_extra', 'var')  || isempty(p_FFT_extra)
  p_FFT_extra=2;
end
if ~exist('conf_level', 'var')  || isempty(conf_level)
  conf_level=0;  % i.e. no confidence intervals
end

[f,...
 Syx, ~, ~, ...
 N_fft, f_res_diam, K, ...
 ~, ~, ...
 ~, ~, ~,...
 ~, ...
 Syxs_tao]=...
  cross_pow_mt(dt,x,...
               NW,K,W_keep,...
               p_FFT_extra,conf_level) ;

N_f = size(Syx,1) ;  % Number of frequencies
assert(isequal(size(Syx),[N_f M M])) ;

% Get the eigenspectra for the main estimate
[V, lambda] = V_and_lambda_from_Syx(Syx) ;
  % V is of shape [N_f M M]
  % lambda is of shape [N_f M]

% If conf_level is zero, don't compute CIs
if conf_level == 0
  V_mag_ci = [] ;
  V_phase_ci = [] ;
  lambda_ci = [] ;
  return
end

% Compute the take-away-one eigenspectra
Vs_tao = zeros([N_f M M R K]) ;
lambdas_tao = zeros([N_f M R K]) ;
for taper_index = 1 : K
  for sample_index = 1 : R
    [Vs_tao(:,:,:,sample_index,taper_index), lambdas_tao(:,:,sample_index,taper_index)] = ...
      V_and_lambda_from_Syx(Syxs_tao(:,:,:,sample_index,taper_index)) ;
      % Syxs_tao is of size [N_f M M R K]
  end
end

% separate out magnitude of the take-away-one eigenspectra
Vs_tao_mag=abs(Vs_tao);  % [N_f M M R K]

% transform the take-away-one eigenspectra magnitudes
Vs_tao_mag_xf=Vs_tao_mag;  % transform is identity function, for now.  [N_f M M R K]

% calculate the sigmas on the eigenspectra magnitudes
Vs_tao_mag_xf_mean=mean(mean(Vs_tao_mag_xf,5),4);  % [N_f M M]
V_mag_xf_sigma=...
  sqrt((R*K-1)/(R*K)*...
       sum(sum((Vs_tao_mag_xf-...
                repmat(Vs_tao_mag_xf_mean,[1 1 1 R K])).^2,5),4));  % [N_f M M]

% calculate the eigenspectra magnitude confidence intervals
V_mag = abs(V) ;  % [N_f M M]
V_mag_xf = V_mag ;  % [N_f M M]  % identity function
ci_factor=tinv((1+conf_level)/2,R*K-1);  % scalar
V_mag_xf_ci = zeros([N_f M M 2]) ;  % [N_f M M 2]
V_mag_xf_ci(:,:,:,1)=V_mag_xf-ci_factor*V_mag_xf_sigma;
V_mag_xf_ci(:,:,:,2)=V_mag_xf+ci_factor*V_mag_xf_sigma;
V_mag_ci=V_mag_xf_ci;  % b/c transform is identity function; [N_f M M 2]

% calculate the eigenspectra phase sigma
Vs_tao_hat=Vs_tao./Vs_tao_mag;  % [N_f M M R K]  % Convert take-away-one eigenspectra to complex numbers with unity magnitude
Vs_tao_hat_mean=mean(mean(Vs_tao_hat,5),4);  % [N_f M M]
arg_sqrt=max(2*(R*K-1)*(1-abs(Vs_tao_hat_mean)),0);  % [N_f M M]
V_phase_sigma=sqrt(arg_sqrt);  % [N_f M M]

% calculate the eigenspectra phase confidence intervals
V_phase = angle(V) ;  % [N_f M M]
V_phase_ci = zeros([N_f M M 2]) ;  % [N_f M M 2]
V_phase_ci(:,:,:,1)=V_phase-ci_factor*V_phase_sigma;
V_phase_ci(:,:,:,2)=V_phase+ci_factor*V_phase_sigma;
% V_phase_ci is of size [N_f M M 2]

% transform the take-away-one eigenvalues
lambdas_tao_xf=log10(lambdas_tao);  % [N_f M R K]

% calculate the sigmas on the transformed eigenvalues
lambdas_tao_xf_mean=mean(mean(lambdas_tao_xf,4),3);  % [N_f M]
lambda_xf_sigma=...
  sqrt((R*K-1)/(R*K)*...
       sum(sum((lambdas_tao_xf-...
                repmat(lambdas_tao_xf_mean,[1 1 R K])).^2,4),3));  % [N_f M]

% calculate the eigenvalue confidence intervals
lambda_xf = log10(lambda) ;  % [N_f M]
lambda_xf_ci = zeros([N_f M 2]) ;  % [N_f M 2]
lambda_xf_ci(:,:,1)=lambda_xf-ci_factor*lambda_xf_sigma; 
lambda_xf_ci(:,:,2)=lambda_xf+ci_factor*lambda_xf_sigma;
lambda_ci=10.^lambda_xf_ci;  % [N_f M 2]

end % function
