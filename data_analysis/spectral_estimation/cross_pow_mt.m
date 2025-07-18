function [f,...
          Syx, Syx_mag, Syx_phase, ...
          N_fft, f_res_diam, K, ...
          Syx_mag_ci, Syx_phase_ci, ...
          Syx_mag_xf, Syx_mag_xf_sigma, Syx_mag_xf_ci,...
          Syx_phase_sigma, ...
          Syxs_tao]=...
  cross_pow_mt(dt,x,...
               nw,K,W_keep,...
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
N=size(x,1);  % number of time points per process sample
M=size(x,2);  % number of signals
R=size(x,3);  % number of samples of the process
fs=1/dt;

% process args
if ~exist('K', 'var') || isempty(K)
  K=2*nw-1;
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

% N for FFT
N_fft=2^(ceil(log2(N))+p_FFT_extra);

% compute frequency resolution
f_res_diam=2*nw/(N*dt);

% generate the dpss tapers if necessary
persistent N_memoed nw_memoed K_memoed tapers_memoed;
if isempty(tapers_memoed) || ...
   N_memoed~=N || nw_memoed~=nw || K_memoed~=K
 %fprintf(1,'calcing dpss...\n');
 tapers_memoed=dpss(N,nw,K);
 N_memoed=N;
 nw_memoed=nw;
 K_memoed=K;
end
tapers=tapers_memoed;
tapers=reshape(tapers,[N 1 1 K]);

% generate the frequency base
% hpfi = 'highest positive frequency index'
hpfi=ceil(N_fft/2);
f=fs*(0:(hpfi-1))'/N_fft;
f=f(f<=W_keep);
N_f=length(f);

% taper and do the FFTs
if N_f*M*R*K<1e5
  % if dimensions are not too big, do this the easy way
  x_tapered = tapers .* x ;  % N x M x R x K
  X = fft(x_tapered,N_fft,1) ;  % N_fft x M x R x K
  X = X(1:N_f,:,:,:) ;  % N_f x M x R x K
else
  % if dimensions are big, do this in a more space-efficient way
  X=zeros([N_f M R K]);
  for r=1:R  % windows
    x_this = x(:,:,r) ;  % N x M
    for k=1:K  % tapers
      taper = tapers(:,:,:,k) ; % N x 1
      x_this_tapered = taper .* x_this ;  % N x M
      X_this = fft(x_this_tapered,N_fft,1) ;  % N_fft x M
      X(:,:,r,k) = X_this(1:N_f,:) ;  % N_f x M
    end
  end
end
% X is of shape [N_f M R K]

% convert to power by squaring, and to a density by dividing by fs
Syxs = zeros([N_f M M R K]) ;
for k=1:K  % tapers
  for r=1:R  % windows
    for ifr = 1:N_f  % frequencies
      X_this = reshape(X(ifr,:,r,k), [M 1]) ;  % want col vector
      Syxs_this = X_this*X_this' ;  % MxM, S(i,j) is s.t. with positive angle means signal i *leads* signal j.
      Syxs(ifr,:,:,r,k) = reshape(Syxs_this,[1 M M]) ;
    end 
  end
end
Syxs = Syxs/fs ;  % of shape [N_f M M R K]

% multiply by 2 to make into one-sided power spectra)
Syxs=2*Syxs;  % of shape [N_f M M R K]

% _sum_ across samples, tapers (keep these around in case we need to 
% calculate the take-away-one spectra for error bars)
SyxRK=sum(sum(Syxs,5),4);  % [N_f M M]

% convert the sum across samples, tapers to an average; these are our 
% 'overall' spectral estimates
Syx=SyxRK/(R*K);  % [N_f M M]

% separate out magnitude, phase
Syx_mag=abs(Syx);  % [N_f M M]
Syx_phase=unwrap(angle(Syx));  % [N_f M M]

% calc the sigmas
if conf_level>0
  % calculate the transformed power
  Syx_mag_xf=log10(Syx_mag);  % [N_f M M]

  % calculate the take-away-one spectra
  Syxs_tao=(repmat(SyxRK,[1 1 1 R K])-Syxs)/(R*K-1);  % [N_f M M R K]
  
  % separate out magnitude
  Syxs_tao_mag=abs(Syxs_tao);  % [N_f M M R K]

  % transform the take-away-one spectra magnitudes
  Syxs_tao_mag_xf=log10(Syxs_tao_mag);  % [N_f M M R K]

  % calculate the sigmas on the spectra magnitudes
  Syxs_tao_mag_xf_mean=mean(mean(Syxs_tao_mag_xf,5),4);  % [N_f M M]
  Syx_mag_xf_sigma=...
    sqrt((R*K-1)/(R*K)*...
         sum(sum((Syxs_tao_mag_xf-...
                  repmat(Syxs_tao_mag_xf_mean,[1 1 1 R K])).^2,5),4));  % [N_f M M]

  % calculate the phase sigma
  Syxs_tao_hat=Syxs_tao./Syxs_tao_mag;  % [N_f M M R K]  % Convert take-away-one cross-powers to unit vectors
  Syxs_tao_hat_mean=mean(mean(Syxs_tao_hat,5),4);  % [N_f M M]
  arg_sqrt=max(2*(R*K-1)*(1-abs(Syxs_tao_hat_mean)),0);  % [N_f M M]
  Syx_phase_sigma=sqrt(arg_sqrt);  % [N_f M M]

  % calculate the magnitude confidence intervals
  ci_factor=tinv((1+conf_level)/2,R*K-1);  % scalar
  Syx_mag_xf_ci(:,:,:,1)=Syx_mag_xf-ci_factor*Syx_mag_xf_sigma;  % [N_f M M]
  Syx_mag_xf_ci(:,:,:,2)=Syx_mag_xf+ci_factor*Syx_mag_xf_sigma;  % [N_f M M]
  Syx_mag_ci=10.^Syx_mag_xf_ci;  % [N_f M M 2]
  Syx_phase_ci(:,:,:,1)=Syx_phase-ci_factor*Syx_phase_sigma;  % [N_f M M]
  Syx_phase_ci(:,:,:,2)=Syx_phase+ci_factor*Syx_phase_sigma;  % [N_f M M]
  % Syx_phase_ci is of size [N_f M M 2]
else
  % just make this stuff empty
  Syx_mag_ci=[];
  Syx_mag_xf=[];
  Syx_mag_xf_sigma=[];
  Syx_mag_xf_ci=[];
  Syx_phase_ci=[] ;
  Syx_phase_sigma=[];
  Syxs_tao = [] ;
end

end  % function
