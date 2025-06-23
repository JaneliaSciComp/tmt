function t=t_from_x(self,x)

x_units=self.x_units;
switch x_units
  case 'time_s',
    t=x;
  case 'time_ms',
    t=x/1000;
  case 'time_min',
    t=x*60;
  case 'time_hr',
    t=x*3600;
  otherwise,
    error('unknown x_units');
end
