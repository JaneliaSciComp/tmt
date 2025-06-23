function str=time_units_string(self)
  x_units=self.x_units;
  switch x_units
    case 'time_s',
      str='s';
    case 'time_ms',
      str='ms';
    case 'time_min',
      str='min';
    case 'time_hr',
      str='hr';
    otherwise,
      error('unknown x_units');
  end
end
