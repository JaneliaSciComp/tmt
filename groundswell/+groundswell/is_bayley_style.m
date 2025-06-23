function p=is_bayley_style(filename)

fid = fopen(filename,'r');
first_line=fgetl(fid);
fclose(fid);
p=strcmp(first_line(1:5),'Frame');

end

