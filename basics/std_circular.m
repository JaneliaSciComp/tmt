function sigma_hat=std_circular(theta,flag,i_dim)

% this estimates the circular variance, using the formulation where it
% approaches the 'linear' variance for a set of angles with small
% dispersion.  Then it takes the square root of that.
% The flag argument works the same as the flag argument for std().  Use
% flag==0 or flag=[], or omit the arg, to get the estimate of
% circular variance that approaches the unbiased estiamte of variance for
% sets of angles with small dispersion.

if nargin<2 || isempty(flag)
  flag=0;
end
if nargin<3
  i_dim=1;
end

n=size(theta,i_dim);
x=cos(theta);
y=sin(theta);
X_bar=mean(x,i_dim);
Y_bar=mean(y,i_dim);
mu_hat=atan2(Y_bar,X_bar);  % estimate of circular mean
repmat_arg=ones(1,ndims(x));
repmat_arg(i_dim)=n;
mu_hat_repped=repmat(mu_hat,repmat_arg);
if flag==0
  denom=n-1;
elseif flag==1
  denom=n;
else
  error('flag argument must be 0, 1, or []');
end
sigma2_hat=2*sum(1-cos(theta-mu_hat_repped),i_dim)/denom;
sigma_hat=sqrt(sigma2_hat);
