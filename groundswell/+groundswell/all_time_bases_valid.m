function result=all_time_bases_valid(t_each)

% we assume only one sweep per signal
% this is currently sufficient

% handle degenerate case
n_trace=length(t_each);
if n_trace==0
  result=false;
  return;
end

% get t0, tf, dt for each timeline
t0_each=zeros(n_trace,1);
tf_each=zeros(n_trace,1);
dt_each=zeros(n_trace,1);
n_t_each=zeros(n_trace,1);
for i=1:n_trace
  t_this=t_each{i};
  t0_each(i)=t_this(1  );
  tf_each(i)=t_this(end);
  n_t_each(i)=length(t_this);
  dt_each(i)=(tf_each(i)-t0_each(i))/(n_t_each(i)-1);
end

% check if all timelines are valid
if all(isfinite(t0_each)) && all(isfinite(tf_each)) && ...
   all(isfinite(dt_each)) && all(n_t_each>=2)
  result=true;
else
  result=false;
end

end
