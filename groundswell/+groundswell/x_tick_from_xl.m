function [x_tick,x_tick_label]=x_tick_from_xl(xl)

% initial stab at tick spacing
x_span=diff(xl);
dx_want=x_span/10;
p=round(log10(dx_want));
dp=max(-p,0);
dx=10^p;

% refine if too many, too few
n_tick_approx=x_span/dx;
if n_tick_approx<=5
  dx=dx/2;
  dp=dp+1;
elseif n_tick_approx>=20
  dx=2*dx;
end

% make the ticks
x0=dx*ceil(xl(1)/dx);
xf=dx*floor(xl(2)/dx);
x_tick=(x0:dx:xf);
n_tick=length(x_tick);

% make tick labels
x_tick_label=cell(n_tick,1);
for i=1:n_tick
  x_tick_label{i}=sprintf(sprintf('%%.%df',dp),x_tick(i));
end

