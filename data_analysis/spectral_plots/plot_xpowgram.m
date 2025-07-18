function plot_xpowgram(ax, ...
                       t,f,...
                       S_mag,S_phase,...
                       t_lim,f_lim,S_mag_lim,...
                       title_str,...
                       S_mag_thresh)

% plot a cohereogram in the current axes                          
                          
% deal with arguments
if nargin<6 || isempty(t_lim)
  dt=(t(end)-t(1))/(length(t)-1);
  t_lim=[t(1)-dt/2 t(end)+dt/2];
end
if nargin<7 || isempty(f_lim)
  f_lim=[f(1) f(end)];
end
if nargin<8 || isempty(S_mag_lim)
  S_mag_lim = max(S_mag, 'all') ;
end
if nargin<9
  title_str='';
end
if nargin<10 || isempty(S_mag_thresh)
  S_mag_thresh=0;
end

% convert to complex coherence
S = S_mag.*exp(1i*S_phase) ;

% do the cohereogram itself
im = xpow2l75_border(S, S_mag_lim, S_mag_thresh) ;
image(ax, t, f, im) ;
axis(ax, 'xy');
ylim(ax, f_lim);
xlim(ax, t_lim);
ylabel(ax, 'Frequency (Hz)');
xlabel(ax, 'Time (s)');
title(ax, title_str,'interpreter','none');
