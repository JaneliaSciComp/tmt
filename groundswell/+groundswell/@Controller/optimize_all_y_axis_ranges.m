function optimize_all_y_axis_ranges(self)

axes_hs=self.view.axes_hs;
t=self.model.t;
data=self.model.data;
[n_t,n_chan,~]=size(data);
tl_view=self.view.tl_view;
jl=interp1([t(1) t(end)],[1 n_t],tl_view,'linear','extrap');
jl(1)=floor(jl(1));
jl(2)= ceil(jl(2));
jl(1)=max(1,jl(1));
jl(2)=min(n_t,jl(2));
for i=1:n_chan
  y_min=min(min(data(jl(1):jl(2),i,:)));  
  y_max=max(max(data(jl(1):jl(2),i,:)));
  y_mid=(y_min+y_max)/2;  y_radius=(y_max-y_min)/2;
  if y_radius==0
    y_radius=1;
  end
  y_lo=y_mid-1.1*y_radius;  y_hi=y_mid+1.1*y_radius;
  set(self.view.axes_hs(i),'YLim',[y_lo y_hi]);
end
