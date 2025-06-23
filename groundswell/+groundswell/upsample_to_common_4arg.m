function [t,data]=upsample_to_common_4arg(t_1,data_1,t_2,data_2)

% We assume only one sweep per signal.
% This is currently sufficient.

% get t0, tf, dt for each timeline
n_t_1=length(t_1);
dt_1=(t_1(end)-t_1(1))/(n_t_1-1);
n_t_2=length(t_2);
dt_2=(t_2(end)-t_2(1))/(n_t_2-1);

% figure out the new shared timeline
t0=max(t_1(1),t_2(1));
tf_approx=min(t_1(end),t_2(end));
dt=min(dt_1,dt_2);
n_t=floor((tf_approx-t0)/dt)+1;

% generate the new timeline
t=t0+dt*(0:(n_t-1))';

% interpolate each signal onto the new timeline
n_signals_1=size(data_1,2);
n_signals_2=size(data_2,2);
n_signals=n_signals_1+n_signals_2;
data=zeros(n_t,n_signals);
data(:,1:n_signals_1)= ...
  interp1(t_1,data_1,t,'linear','extrap');
data(:,n_signals_1+1:end)= ...
  interp1(t_2,data_2,t,'linear','extrap');
% for i=1:n_signals_1
%   data(:,i)=pchip(t_1,data_1(:,i),t);
% end
% j=1;
% for i=n_signals_1+1:n_signals
%   data(:,i)=pchip(t_2,data_2(:,j),t);
%   j=j+1;
% end
