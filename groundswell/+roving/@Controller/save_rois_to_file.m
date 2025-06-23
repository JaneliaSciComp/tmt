function save_rois_to_file(self)

% get the ROI info from the figure state
n_roi=length(self.model.roi);
r_border={self.model.roi.border}';
label={self.model.roi.label}';
% border_h=[self.roi_struct.border_h]';
% label_h=[self.roi_struct.label_h]';

% throw up the dialog box
[filename,pathname]= ...
  uiputfile({'*.rpb' 'ROI polygonal boundary file (*.rpb)'}, ...
            'Save ROIs to File...');
if isnumeric(filename) || isnumeric(pathname)
  % this happens if user hits Cancel
  return;
end
full_filename=strcat(pathname,filename);

%
% Write the ROI borders to the file
%

% open the file for writing
fid=fopen(full_filename,'w','ieee-be');
if (fid == -1)
  errordlg(sprintf('Unable to open file %s',filename),...
           'File Error');
  return;
end

% write the number of ROIs
count=fwrite(fid,n_roi,'uint32');
if (count ~= 1)
  errordlg(sprintf('Error writing ROIs to file %s',filename),...
           'File Error');
  fclose(fid);
  delete(filename);
  return;
end

% for each ROI, write a label and a vertex list
for j=1:n_roi
  % first the label
  label_string=label{j};
  n_chars=length(label_string);
  fwrite(fid,n_chars,'uint32');
  count=fwrite(fid,label_string,'uchar');
  if (count ~= n_chars)
    errordlg(sprintf('Error writing ROIs to file %s',filename),...
             'File Error');
    fclose(fid);
    delete(filename);
    return;
  end
  % then the vertex list
  vl=r_border{j};
  n_vertices=size(vl,2);
  % write it
  fwrite(fid,n_vertices,'uint32');
  count=fwrite(fid,vl,'float32');
  if (count ~= 2*n_vertices)
    errordlg(sprintf('Error writing ROIs to file %s',filename),...
             'File Error');
    fclose(fid);
    delete(filename);
    return;
  end
end  

% close the file
fclose(fid);

