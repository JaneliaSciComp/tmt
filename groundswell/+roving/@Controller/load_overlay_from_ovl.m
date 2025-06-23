function load_overlay_from_ovl(self,filename,pathname)

%
% Open the .ovl file (actually a .mat file), prepare for reading.
%

import roving.Overlay_file_reader;

% open the file
full_filename=strcat(pathname,filename);
self.model.overlay_file=Overlay_file_reader(full_filename);
% if (fid == -1)
%   errordlg(sprintf('Unable to open file %s',filename),...
%            'File Error');
%   return;
% end

% notify the view
self.view.new_overlay();

end
