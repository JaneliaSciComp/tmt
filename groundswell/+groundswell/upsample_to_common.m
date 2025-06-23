function [t,data]=upsample_to_common(t_each,data_each)

% We assume only one sweep per signal.
% This is currently sufficient.
% We assume there are at least two signals.  If we get here and this is
% not the case, something has gone wrong elsewhere.

% get t0, tf, dt for each timeline
n_signals=length(t_each);
t0_each=zeros(n_signals,1);
tf_each=zeros(n_signals,1);
dt_each=zeros(n_signals,1);
n_t_each=zeros(n_signals,1);
for i=1:n_signals
  t_this=t_each{i};
  t0_each(i)=t_this(1  );
  tf_each(i)=t_this(end);
  n_t_each(i)=length(t_this);
  dt_each(i)=(tf_each(i)-t0_each(i))/(n_t_each(i)-1);
end

% figure out the new shared timeline
t0=max(t0_each);
tf_approx=min(tf_each);
dt=min(dt_each);
n_t=floor((tf_approx-t0)/dt)+1;

% generate the new timeline
t=t0+dt*(0:(n_t-1))';

% interpolate each signal onto the new timeline
data=zeros(n_t,n_signals);
for i=1:n_signals
  data(:,i)=interp1(t_each{i},data_each{i},t,'linear','extrap');
end
