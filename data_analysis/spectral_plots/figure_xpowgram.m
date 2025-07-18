function [fig,ax] = ...
  figure_xpowgram(t,f,...
                  S_mag,S_phase,...
                  t_lim,f_lim,S_mag_lim,...
                  title_str,...
                  S_mag_thresh)

% deal with arguments
if nargin<5 || isempty(t_lim)
  dt=(t(end)-t(1))/(length(t)-1);
  t_lim=[t(1)-dt/2 t(end)+dt/2];
end
if nargin<6 || isempty(f_lim)
  f_lim=[f(1) f(end)];
end
if nargin<7 || isempty(S_mag_lim)
  S_mag_lim = max(S_mag, 'all') ;
end
if nargin<8
  title_str='';
end
if nargin<9 || isempty(S_mag_thresh)
  S_mag_thresh=0;
end

% do the gram itself
fig=figure();
ax=axes();
plot_xpowgram(ax,...
              t,f,...
              S_mag,S_phase,...
              t_lim,f_lim,S_mag_lim,...
              title_str,...
              S_mag_thresh);

% draw the colorbar
% The cohgram plot just shows an RGB image that we specify directly.
% So we just impose a colormap that we're not really using, then make a
% colorbar based on that.
cmap_phase=l75_border(256);  % to show abs(C)==1 colors
colormap(ax, cmap_phase) ;
ax.CLim = [-180 +180] ;
cb=colorbar(ax) ;
%colorbar_image_h=findobj(colorbar_h,'Tag','TMW_COLORBAR');
%set(colorbar_image_h,'YData',[-180 +180]);
%set(colorbar_h,'YLim',[-180 +180]);
%set(colorbar_image_h,'CData',reshape(cmap_phase,[256 1 3]));
set(cb,'YTick',[-180 -90 0 +90 +180]);
ylabel(cb, 'Phase (deg), for |S|=max', 'Rotation', 270) ;

end
