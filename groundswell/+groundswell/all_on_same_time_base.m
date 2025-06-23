function result=all_on_same_time_base(t_each)

% we assume only one sweep per signal
% this is currently sufficient

% handle degenerate case
n_trace=length(t_each);
if n_trace==0
  result=true;
  return;
end

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

% check if all timelines are the same
% if so, no need for resampling
if all(t0_each==t0_each(1)) && all(tf_each==tf_each(1)) && ...
   all(n_t_each==n_t_each(1))
  result=true;
else
  result=false;
end

end
