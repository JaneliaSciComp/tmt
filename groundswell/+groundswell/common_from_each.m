function [data,t]=common_from_each(t_each,data_each)

% Converts a bunch of traces that have identical time bases to
% a single time base, and puts all the data in a single array.
% Don't use this if t_each{i}~=t_each{j} for any i, j.

t=t_each{1};
n_t=length(t);
n_signals=length(data_each);
data=zeros(n_t,n_signals);
for i=1:n_signals
  data(:,i)=data_each{i};
end

end
