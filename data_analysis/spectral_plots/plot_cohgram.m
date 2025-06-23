function plot_cohgram(t,f,C_mag,C_phase,...
                      t_lim,f_lim,...
                      title_str,...
                      C_mag_thresh)

% plot a cohereogram in the current axes                          
                          
% deal with arguments
if nargin<5 || isempty(t_lim)
  dt=(t(end)-t(1))/(length(t)-1);
  t_lim=[t(1)-dt/2 t(end)+dt/2];
end
if nargin<6 || isempty(f_lim)
  f_lim=[f(1) f(end)];
end
if nargin<7
  title_str='';
end
if nargin<8 || isempty(C_mag_thresh)
  C_mag_thresh=0;
end

% convert to complex coherence
C=C_mag.*exp(1i*C_phase);  

% do the cohereogram itself
im=coh2l75_border(C,C_mag_thresh);
image(t,f,im);
axis xy;
ylim(f_lim);
xlim(t_lim);
ylabel('Frequency (Hz)');
xlabel('Time (s)');
title(title_str,'interpreter','none');
