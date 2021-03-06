function figure_classic_phase(phi_mean,phi_sd,cell_color,edge_color)

% set constants
PD_off=1;
LP_on=2;
LP_off=3;
PY_on=4;
PY_off=5;
PD=1;
LP=2;
PY=3;
cell_label={'PD' 'LP' 'PY'}';
gray=0.5*[1 1 1];

% make the fig
figure;
set_figure_size([8 3]);
axes;
set(gca,'layer','top');
set(gca,'fontsize',14);
set(gca,'linewidth',1);
set(gca,'ydir','reverse');
box off;
xlim([0 1.1])
ylim([0 4]);
set(gca,'ytick',[1 2 3]);
set(gca,'yticklabel',cell_label);
line([1 1],ylim,[-2 -2],'linewidth',1,'color',gray);
line([phi_mean(PD_off) phi_mean(PD_off)+phi_sd(PD_off)],...
     [PD PD],...
     [-1 -1],...
     'linewidth',2,'color',edge_color(PD_off,:));
line([phi_mean(LP_on ) phi_mean(LP_on )-phi_sd(LP_on )],...
     [LP LP],[-1 -1],'linewidth',2,'color',edge_color(LP_on ,:));
line([phi_mean(LP_off) phi_mean(LP_off)+phi_sd(LP_off)],[LP LP],[-1 -1],'linewidth',2,'color',edge_color(LP_off,:));
line([phi_mean(PY_on ) phi_mean(PY_on )-phi_sd(PY_on )],[PY PY],[-1 -1],'linewidth',2,'color',edge_color(PY_on ,:));
line([phi_mean(PY_off) phi_mean(PY_off)+phi_sd(PY_off)],[PY PY],[-1 -1],'linewidth',2,'color',edge_color(PY_off,:));
patch(phase_rect_x([0 phi_mean(PD_off)],PD),...
      phase_rect_y([0 phi_mean(PD_off)],PD),...
      cell_color(PD,:),...
      'edgecolor','none');
patch(phase_rect_x([phi_mean(LP_on) phi_mean(LP_off)],LP),...
      phase_rect_y([phi_mean(LP_on) phi_mean(LP_off)],LP),...
      cell_color(LP,:),...
      'edgecolor','none');
patch(phase_rect_x([phi_mean(PY_on) phi_mean(PY_off)],PY),...
      phase_rect_y([phi_mean(PY_on) phi_mean(PY_off)],PY),...
      cell_color(PY,:),...
      'edgecolor','none');
xlabel('Phase (cycles)');
set(gca,'position',scale_position(get(gca,'position'),[1 .9]));
% text(0.2,2.15,...
%      sprintf('%d animals\n%d cycles',n_animals,n_cycles),...
%      'units','inches',...
%      'color',species_color{crab},...
%      'fontsize',14,...
%      'horizontalalignment','left',...
%      'verticalalignment','middle');