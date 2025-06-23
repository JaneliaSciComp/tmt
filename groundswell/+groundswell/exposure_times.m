function [t_frame,T_frame,dt_frame_start,dt_frame_end,...
          i_rising,i_falling] = ...
  exposure_times(t,exposure_bool)

% Returns information about the timing of TTL pulses in exposure_bool.
% This includes the center of each high pulse, the duration of each high
% pulses, the offset of each rising edge relative to the center of each
% high pulse, the offset of each falling edge relative to the center of
% each high pulse, the index of each rising edge, and the index of each
% falling edge.  (These last two give the index of the element _before_ the
% edge in question.)
%
% If exposure_bool starts and ends low, that's pretty much the end of the
% story.  But if exposure_bool starts high, the "center" of the first pulse
% is assumed to be t(1), and all the quantities associated with the first
% pulse that would require knowledge of its rising edge are set to nan.
%
% Similarly, if exposure_bool ends high, the "center" of the last pulse
% is assumed to be t(1), and all the quantities associated with the last
% pulse that would require knowledge of its falling edge are set to nan.
%
% The above pecularities are based on a common use-case, where the exposure
% signal is cropped when ROI signals are added to an existing set of
% traces, one of which is the camera exposure signal.  This leads to a
% situation where the traces all start at the center point of the first
% pulse, and end at the center point of the last pulse.  These pecularities
% are engineered such that if the user then wants to add addiitonal signals
% with each sample corresponding to a frame, this function will get the
% center time of the exposures correct (including the first and last
% exposures).

% The boolean exposure signal tells when the CCD is being exposed.
% We assume t, exposure are column vectors.

n_samples=length(t);
edge=ttl_edges(exposure_bool);
if exposure_bool(1)
  %warning('groundswell:exposure_starts_high', ...
  %        'exposure starts high!');
  % eliminate first falling edge
  i_edge=find(edge==(-1));
  edge(i_edge(1))=0;
  starts_high=true;
  i_falling_initial=i_edge(1);
else
  starts_high=false;
end
if exposure_bool(end)
  %warning('groundswell:exposure_ends_high', ...
  %        'exposure ends high!');
  % eliminate last rising edge
  i_edge=find(edge==(+1));
  edge(i_edge(end))=0;  
  ends_high=true;
  i_rising_final=i_edge(end);
else
  ends_high=false;
end

% The ith rising edge marks the start of the ith frame
i_rising=find(edge==(+1));
i_falling=find(edge==(-1));
% i_rising and i_falling should be the same length
t_frame_start=(t(i_rising)+t(i_rising+1))/2;
t_frame_end=(t(i_falling)+t(i_falling+1))/2;
t_frame=(t_frame_start+t_frame_end)/2;
T_frame=t_frame_end-t_frame_start;  % frame duration
dt_frame_start=t_frame_start-t_frame;
dt_frame_end=t_frame_end-t_frame;

% deal with special cases
if starts_high
  t_frame=[t(1);t_frame];
  T_frame=[nan;T_frame];
  dt_frame_start=[nan;dt_frame_start];
  dt_frame_end=[t(i_falling_initial)-t(1);dt_frame_end];
  i_rising=[nan;i_rising];
  i_falling=[i_falling_initial;i_falling];
end
if ends_high
  t_frame=[t_frame;t(end)];
  T_frame=[T_frame;nan];
  dt_frame_start=[dt_frame_start;t(i_rising_final)-t(end)];
  dt_frame_end=[dt_frame_end;nan];
  i_rising=[i_rising;i_rising_final];
  i_falling=[i_falling_initial;nan];
end

end
