function filename_abs=absolute_filename(filename)

if groundswell.is_filename_absolute(filename)
  filename_abs=filename;
else
  filename_abs=fullfile(pwd(),filename);
end

end

