function [Sxx_line, Sxx_eb_patch]=...
  plot_pow(ax,...
           f,Sxx,...
           Sxx_ci,...
           f_lim,Sxx_lim,...
           title_str, ...
           x_units_str)

% figure_pow(f,Sxx) plots the given power spectrum
% in a new figure

% deal with args
if ~exist('Sxx_ci','var') || isempty(Sxx_ci)
  Sxx_ci=[];
end
if ~exist('f_lim','var') || isempty(f_lim)
  f_lim=[0 f(end)];
end
if ~exist('Sxx_lim','var') || isempty(Sxx_lim)
  Sxx_lim=[0 1.05*max(Sxx)];
elseif isscalar(Sxx_lim)
  Sxx_lim=[0 Sxx_lim];  
end
if ~exist('title_str','var') || isempty(title_str)
  title_str='';
end
if ~exist('x_units_str','var') || isempty(x_units_str)
  x_units_str='arbs';
end

if ~isempty(Sxx_ci)
  Sxx_eb_patch=...
    patch_eb(f,...
             Sxx_ci,...
             [0.75 0.75 0.75],...
             'EdgeColor','none', ...
             'Parent',ax);
else
  Sxx_eb_patch=[];
end
Sxx_line=line(ax,f,Sxx,zeros(size(f)),'Color',[0 0 0]);
xlim(ax,f_lim);
ylim(ax,Sxx_lim);
set(ax,'Layer','Top');
set(ax,'Box','on');
ylabel(ax,sprintf('Power Density (%s^2/Hz)', x_units_str));
xlabel(ax,'Frequency (Hz)');    
title(ax,title_str,'interpreter','none');
