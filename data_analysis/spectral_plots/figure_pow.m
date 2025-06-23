function [fig, ax, Sxx_line, Sxx_eb_patch]=...
  figure_pow(f,Sxx,...
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

% make the figure
fig=figure('color','w');

% make the plots
ax=axes('Parent',fig);

% Plot into the ax axes
[Sxx_line, Sxx_eb_patch] = ...
  plot_pow(ax,...
           f,Sxx,...
           Sxx_ci,...
           f_lim,Sxx_lim,...
           title_str, ...
           x_units_str) ;