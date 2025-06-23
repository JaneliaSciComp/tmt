function refresh_traces(self,force_resample)

% Function to re-draw the traces in the axes.  Called, for instance, when
% the time limits are changed.  Manages the business of resampling the
% traces so that we don't plot way for points than there are horizontal
% pixels in the axeses.

% args
if nargin<2 || isempty(force_resample)
  force_resample=false;
end

% check for an empty model
if isempty(self.model)
  return;
end

% get vars we need
axes_hs=self.axes_hs;
t=self.model.t;
data=self.model.data;
[n_t,n_chan,n_sweeps]=size(data);
r=self.r;
t_sub=self.t_sub;
data_sub_min=self.data_sub_min;
data_sub_max=self.data_sub_max;
tl_view=self.tl_view;

% figure out what the subsampling _should_ be
t0=t(1);
tf=t(end);
dt=(tf-t0)/(n_t-1);
tw=diff(tl_view);
n_t_view=tw/dt;
pos=get(axes_hs(1),'position');
n_pels_view=pos(3);
samples_per_pel=n_t_view/n_pels_view;
if samples_per_pel>100
  % figure out how much we're going to subsample
  samples_per_pel_want=2;
  n_t_view_want=n_pels_view*samples_per_pel_want;
  r_new=floor(n_t_view/n_t_view_want);
else
  r_new=1;
end

% subsample, if we're going to
if r~=r_new || force_resample
  if r_new==1
    % don't subsample
    r=1;
    t_sub=[];
    data_sub_min=[];
    data_sub_max=[];
    self.r=r;
    self.t_sub=t_sub;
    self.data_sub_min=data_sub_min;
    self.data_sub_max=data_sub_max;
  else
    % subsample
    r=r_new;
    % subsample the data in a fancy way
    self.hourglass();
    %tic
    t_sub=t(1:r:end);
    n_t_sub=length(t_sub);

    % try doing this by hand, such that it gets compiled
    % this is faster than blkproc(), and faster than the original
    % by-hand version, presumably because this version doesn't do a
    % "if mod(i,r)==0" for each element of data
    %disp('by hand, v2');
    %tic
    data_sub_max=zeros(n_t_sub,n_chan,n_sweeps);
    data_sub_min=zeros(n_t_sub,n_chan,n_sweeps);
    for k=1:n_sweeps
      for j=1:n_chan
        i=1;
        for i_sub=1:(n_t_sub-1)
          mx=-inf; 
          mn=+inf;
          for i_offset=1:r
            d=data(i,j,k);
            if d>mx
              mx=d;
            end
            if d<mn
              mn=d;
            end
            i=i+1;
          end
          data_sub_max(i_sub,j,k)=mx;
          data_sub_min(i_sub,j,k)=mn;
        end
        % the last block may have less than r elements
        mx=-inf;
        mn=+inf;
        n_t_left=n_t-r*(n_t_sub-1);
        for i_offset=1:n_t_left
          d=data(i,j,k);
          if d>mx
            mx=d;
          end
          if d<mn
            mn=d;
          end
          i=i+1;
        end
        data_sub_max(n_t_sub,j,k)=mx;
        data_sub_min(n_t_sub,j,k)=mn;
      end
    end      
    %toc  
    
    self.r=r;
    self.t_sub=t_sub;
    self.data_sub_min=data_sub_min;
    self.data_sub_max=data_sub_max;
    %toc
    self.unhourglass();
  end
end

% shorten the data, and plot
if r==1
  % data not subsampled
  % get subset of the data that will be in view
  t0=t(1);
  tf=t(end);
  j0=floor(interp1([t0 tf],[1 n_t],...
                   tl_view(1),'linear','extrap'));
  jf= ceil(interp1([t0 tf],[1 n_t],...
                   tl_view(2),'linear','extrap'));
  j0=max(1,j0);
  jf=min(n_t,jf);
  t_short=t(j0:jf);
  data_short=data(j0:jf,:,:);
  % change all the lines and axis limits
  x_short=self.x_from_t(t_short);
  xl_view_new=self.x_from_t(tl_view);
  [x_tick,x_tick_label]=groundswell.x_tick_from_xl(xl_view_new);
  for i=1:n_chan
    h=findobj(axes_hs(i),'tag','trace');
    for j=1:n_sweeps
      set(h(j),'xdata',x_short,...
               'ydata',data_short(:,i,j),...
               'visible','on');
    end
  end
  set(axes_hs,'xlim',xl_view_new);
  set(axes_hs,'xtick',x_tick);
  set(axes_hs(n_chan),'xticklabel',x_tick_label);    
else
  % data is subsampled  
  % get subset of the data that will be in view
  n_t_sub=length(t_sub);
  t0=t_sub(1);
  tf=t_sub(end);
  j0=floor(interp1([t0 tf],[1 n_t_sub],...
                   tl_view(1),'linear','extrap'));
  jf= ceil(interp1([t0 tf],[1 n_t_sub],...
                   tl_view(2),'linear','extrap'));
  j0=max(1,j0);
  jf=min(n_t_sub,jf);
  t_sub_short=t_sub(j0:jf);
  data_sub_min_short=data_sub_min(j0:jf,:,:);
  data_sub_max_short=data_sub_max(j0:jf,:,:);
  % make the ready-for-drawing arrays
  n_t_sub_short=length(t_sub_short);
  t_sub_short_draw=nan(2*n_t_sub_short,1);
  t_sub_short_draw(1:2:end)=t_sub_short;
  t_sub_short_draw(2:2:end)=t_sub_short;
  data_sub_short_draw=nan(2*n_t_sub_short,n_chan,n_sweeps);
  data_sub_short_draw(1:2:end,:,:)=data_sub_max_short;
  data_sub_short_draw(2:2:end,:,:)=data_sub_min_short;
  % change all the lines and axis limits
  x_sub_short_draw=...
    self.x_from_t(t_sub_short_draw);
  xl_view_new=self.x_from_t(tl_view);
  [x_tick,x_tick_label]=groundswell.x_tick_from_xl(xl_view_new);
  for i=1:n_chan
    h=findobj(axes_hs(i),'tag','trace');
    for j=1:n_sweeps
      set(h(j),'xdata',x_sub_short_draw,...
               'ydata',data_sub_short_draw(:,i,j),...
               'visible','on');
    end
  end
  set(axes_hs,'xlim',xl_view_new);
  set(axes_hs,'xtick',x_tick);
  set(axes_hs(n_chan),'xticklabel',x_tick_label);  
end

% % update the figure
% drawnow('update');
% drawnow('expose');

end  % function
