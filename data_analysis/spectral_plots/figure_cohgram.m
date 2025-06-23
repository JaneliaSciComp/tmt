function [h,h_a]=figure_cohgram(t,f,C_mag,C_phase,...
                                t_lim,f_lim,...
                                title_str,...
                                C_mag_thresh)

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
h=figure();
h_a=axes();
plot_cohgram(t,f,C_mag,C_phase,...
             t_lim,f_lim,...
             title_str,...
             C_mag_thresh);

% draw the colorbar
% The cohgram plot just shows an RGB image that we specify directly.
% So we just impose a colormap that we're not really using, then make a
% colorbar based on that.
cmap_phase=l75_border(256);  % to show abs(C)==1 colors
colormap(h_a, cmap_phase) ;
h_a.CLim = [-180 +180] ;
colorbar_h=colorbar(h_a) ;
%colorbar_image_h=findobj(colorbar_h,'Tag','TMW_COLORBAR');
%set(colorbar_image_h,'YData',[-180 +180]);
%set(colorbar_h,'YLim',[-180 +180]);
%set(colorbar_image_h,'CData',reshape(cmap_phase,[256 1 3]));
set(colorbar_h,'YTick',[-180 -90 0 +90 +180]);
ylabel(colorbar_h, 'Phase (deg), for |C|=1', 'Rotation', 270) ;

end

