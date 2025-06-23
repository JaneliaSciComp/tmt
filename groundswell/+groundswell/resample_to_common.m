function data=resample_to_common(t,data_original, ...
                                 data_new)

% Resamples data_new onto the time base t.  
% data_new(1,:) is assumed to happen at t(1), and
% data_new(end,:) is assumed to happen at t(end), with
% uniform spacing for other samples.  Currently we just do simple
% linear interpolation.
%                                        
% We assume only one sweep per signal.
% This is currently sufficient.

% get dimensions of original data
[n_t,n_signals_original]=size(data_original);
t0=t(1);
tf=t(end);

% Compute inferred spacing for new data
[n_t_new,n_signals_new]=size(data_new);
dt_new=(tf-t0)/(n_t_new-1);
t_new=t0+dt_new*(0:(n_t_new-1))';

% interpolate new data onto the timeline
data=zeros(n_t,n_signals_original+n_signals_new);
data(:,1:n_signals_original)=data_original;
data(:,n_signals_original+1:end)= ...
  interp1(t_new,data_new,t,'linear','extrap');

end
