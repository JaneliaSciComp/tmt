function x=x_from_t(self,t)

x_units=self.x_units;
switch x_units
  case 'time_s',
    x=t;
  case 'time_ms',
    x=1000*t;
  case 'time_min',
    x=t/60;
  case 'time_hr',
    x=t/3600;
  otherwise,
    error('unknown x_units');
end
