classdef Model < handle

  properties
    t0;
    dt;
    file_name  % the name of the video file currently open
    file;  % the handle of a VideoFile object, the current file (or empty)   
    roi;  % n_roi x 1 struct with fields border and label
    overlay_file;  
      % an Overlay_file_reader object containing frame overlays, or empty
  end  % properties
  
  properties (Dependent=true)
    fs;  % Hz, sampling rate for playback & export, possibly different from 
         % that in file
    n_rows;
    n_cols;
    n_frames;  % number of time samples
    tl;  % 2x1 matrix holding min, max time
    n_rois;
    t;  % a complete timeline for all frames
    a_video_is_open;  % true iff a video is currently open
  end
  
  methods
    % ---------------------------------------------------------------------
    function self=Model()
      self.file_name='';
      self.file=[];
      self.t0=[];  % s
      self.dt=[];  % s
      self.roi=struct('border',cell(0,1), ...
                      'label',cell(0,1));
      self.overlay_file=[];                    
    end  % function
    
    % ---------------------------------------------------------------------
    function t=get.t(self)
      if ~isempty(self.t0) && ~isempty(self.dt) && ~isempty(self.n_frames)
        t=self.t0+self.dt*(0:(self.n_frames-1))';
      else
        t=[];
      end
    end
    
    % ---------------------------------------------------------------------
    function fs=get.fs(self)
      if isempty(self.dt)
        fs=[];
      else
        fs=1/self.dt;
      end
    end
    
    % ---------------------------------------------------------------------
    function n_row=get.n_rows(self)
      if isempty(self.file)
        n_row=[];
      else
        n_row=self.file.n_row;
      end
    end
    
    % ---------------------------------------------------------------------
    function n_col=get.n_cols(self)
      if isempty(self.file)
        n_col=[];
      else
        n_col=self.file.n_col;
      end
    end
    
    % ---------------------------------------------------------------------
    function n_frame=get.n_frames(self)
      if isempty(self.file)
        n_frame=[];
      else
        n_frame=self.file.n_frame;
      end
    end
    
    % ---------------------------------------------------------------------
    function n_roi=get.n_rois(self)
      n_roi=length(self.roi);
    end

    % ---------------------------------------------------------------------
    function tl=get.tl(self)
      t0=self.t0;
      dt=self.dt;
      if ~isempty(self.t0) && ~isempty(self.dt)
        n_frame=self.n_frames;
        if isempty(n_frame) || (n_frame==0) ,
          tl=[];
        else
          tl=t0+[0 dt*(n_frame-1)];
        end
      else
        tl=[];
      end
    end
    
    % ---------------------------------------------------------------------
    function set.dt(self,dt)
      self.dt=dt;
    end
    
%     function sync_t(self)
%       t0=self.t0;
%       dt=self.dt;
%       n_frame=self.n_frames;
%       self.t=t0+dt*(0:(n_frame-1))';
%     end

    % ---------------------------------------------------------------------
    function set.fs(self,fs)
      self.dt=1/fs;
    end
    
    % ---------------------------------------------------------------------
    function add_roi(self,border,label)
      % border 2 x n_vertex, label a string
      n_roi_old=length(self.roi);
      self.roi(n_roi_old+1).border=border;
      self.roi(n_roi_old+1).label=label;
    end
    
    % ---------------------------------------------------------------------
    function delete_rois(self,i_to_delete)
      keep=true(size(self.roi));
      keep(i_to_delete)=false;
      self.roi=self.roi(keep);
    end
    
    % ---------------------------------------------------------------------
    function set_roi(self,border,label)
      % border, label cell arrays
      n_roi=length(border);
      self.roi=struct('border',cell(n_roi,1), ...
                      'label',cell(n_roi,1));
      [self.roi.border]=deal(border{:});
      [self.roi.label]=deal(label{:});
    end
    
    % ---------------------------------------------------------------------
    function in_use=label_in_use(self,label_test)
      labels={self.roi.label};
      in_use=any(strcmp(label_test,labels));
    end

    % ---------------------------------------------------------------------
    function frame=get_frame(self,i)
      frame=self.file.get_frame(i);
    end

    % ---------------------------------------------------------------------
    function frame_overlay=get_frame_overlay(self,i)
      if (1<=i) && (i<=self.overlay_file.n_frames)
        frame_overlay=self.overlay_file.read_frame_overlay(i);
      else
        frame_overlay=cell(0,1);  % just return empty overlay
      end
    end
    
%   Since we now are keeping the movie on-disk, mutating it becomes 
%   more problematical...
%     function motion_correct(self)
%       border=2;  % border to ignore, seems to help with nans and such at the
%                  % edge of the frames
%       % find the translation for each frame
%       options=optimset('maxfunevals',1000);
%       n_frames=self.n_frames;
%       self.file.to_start();
%       if n_frames>0
%         frame_first=double(self.file.get_next());
%       end
%       b_per_frame=zeros(2,n_frames);
%       for k=2:n_frames
%         frame_this=double(self.file.get_next());
%         b_per_frame(:,k)=...
%           find_translation(frame_first, ...
%                            frame_this, ...
%                            border,...
%                            b_per_frame(:,k-1),...
%                            options);
%       end
%       % register each frame using the above-determined translation
%       for k=2:n_frames
%         % implicit conversion to the type of self.data
%         self.data(:,:,k)=register_frame(double(self.data(:,:,k)), ...
%                                         eye(2), ...
%                                         b_per_frame(:,k));
%       end      
%     end  % motion_correct
    
    % ---------------------------------------------------------------------
    function [d_min,d_max]=min_max(self,i)
      % get the max and min values of frame i
      % d_min and d_max are doubles, regardless the type of self.data
      frame=double(self.get_frame(i));
      d_min=min(min(frame));
      d_max=max(max(frame));
    end  % data_bounds
    
%     function [h,t]=hist(self,i,n_bins)
%       % construct a histogram of the data values in frame i
%       frame=double(self.get_frame(i));
%       [h,t]=hist(frame(:),n_bins);
%     end

%     function [h,t]=hist_abs(self,i,n_bins)
%       frame=double(self.get_frame(i));
%       frame=abs(frame);
%       [h,t]=hist(frame(:),n_bins);
%     end

    % ---------------------------------------------------------------------
    function [d_05,d_95]=five_95(self,i)
      % d_05 and d_95 are doubles, regardless the type of self.data
      frame=double(self.get_frame(i));
      d=roving.quantile_mine(frame(:),[0.05 0.95]');
      d_05=d(1);
      d_95=d(2);
    end  % five_95
    
    % ---------------------------------------------------------------------
    function d_max=max_abs(self,i)
      % d_max is a double, regardless of the type of self.data
      frame=double(self.get_frame(i));
      d_max=max(max(abs(frame)));
    end  % max_abs
    
    % ---------------------------------------------------------------------
    function d_90=abs_90(self,i)
      % d_90 is a double, regardless the type of self.data
      frame=abs(double(self.get_frame(i)));
      d_90=roving.quantile_mine(frame(:),0.9);
    end  % five_95
    
    % ---------------------------------------------------------------------
    function [d_min,d_max]=pixel_data_type_min_max(self)
      if self.file.bits_per_pel==8
        d_min=0;
        d_max=255;
      elseif self.file.bits_per_pel==16
        d_min=0;
        d_max=65535;
      else
        % This should not ever happen.
        d_min=0;
        d_max=1;
      end
        
    end

    % ---------------------------------------------------------------------
    function x_roi=mean_over_rois(self)
      % get a mask for each roi
      n_rows=self.n_rows;
      n_cols=self.n_cols;
      roi_stack= ...
        roving.roi_list_to_stack(self.roi,n_rows,n_cols);
      
      % analyze each of the rois
      n_frames=self.n_frames;
      n_rois=self.n_rois;
      n_pels=reshape(sum(sum(roi_stack,2),1),[n_rois 1]);  % pels in each roi
      %n_ppf=n_row*n_col;  % pixels per frame
      x_roi=zeros(n_frames,n_rois);

      % is this faster?  yes.  screw you, JIT compiler.
      for k=1:n_frames
        frame_this=self.get_frame(k);
        for l=1:n_rois
          roi_mask=roi_stack(:,:,l);
          s=sum(sum(roi_mask.*double(frame_this)));
          x_roi(k,l)=s/n_pels(l);
        end
      end
    end  % mean_over_rois()
    
    % ---------------------------------------------------------------------
    function open_video_given_file_name(self,file_name)
      % filename is a filename, can be relative or absolute
      
      % break up the file name
      %[~,base_name,ext]=fileparts(filename);
      %filename_local=[base_name ext];

      % load the optical data
      file=roving.Video_file(file_name);

      % OK, now actually store the data in ourselves
      % make up a t0, get dt
      self.t0=0;
      self.dt=file.dt;  % s

      % set the model
      self.file=file;
      self.file_name=file_name;
    end  % method
    
    % ---------------------------------------------------------------------
    function close_video(self)
      if ~isempty(self.file)
        %self.file.close();
        self.file=[];  % should close file handles
      end
      self.file_name='';
      self.t0=[];
      self.dt=[];  % s
      self.roi=struct('border',cell(0,1), ...
                      'label',cell(0,1));
      if ~isempty(self.overlay_file)
        self.overlay_file.close();
        self.overlay_file=[];
      end
    end  % method
    
    % ---------------------------------------------------------------------
    function result=get.a_video_is_open(self)
      result=~isempty(self.file);
    end  % method

    % ---------------------------------------------------------------------
    function load_rois_from_rpb(self,full_filename)
      %
      % load in the ROI data from the file, w/ error checking
      %

      % open the file
      %full_filename=strcat(pathname,filename);
      [~,basename,ext]=fileparts(full_filename);
      filename=[basename ext];
      fid=fopen(full_filename,'r','ieee-be');
      if (fid == -1)
        error('roving.Model:unableToOpenFile', ...
              sprintf('Unable to open file %s',filename));  %#ok
      end

      % read the number of rois
      [n_rois,count]=fread(fid,1,'uint32');
      %n_rois
      if (count ~= 1)
        fclose(fid);
        error('roving.Model:unableToLoadROIs', ...
              sprintf('Error loading ROIs from file %s',filename));  %#ok
      end

      % dimension cell arrays to hold the ROI labels and vertex lists
      labels=cell(n_rois,1);
      borders=cell(n_rois,1);

      % for each ROI, read the label and the vertex list
      for j=1:n_rois
        % the label
        [n_chars,count]=fread(fid,1,'uint32');
        if (count ~= 1)
          fclose(fid);
          error('roving.Model:unableToLoadROIs', ...
                sprintf('Error loading ROIs from file %s',filename));  %#ok
        end
        [temp,count]=fread(fid,[1 n_chars],'uchar');
        if (count ~= n_chars)
          fclose(fid);
          error('roving.Model:unableToLoadROIs', ...
                sprintf('Error loading ROIs from file %s',filename));  %#ok
        end
        labels{j}=char(temp);
        % the vertex list
        [n_vertices,count]=fread(fid,1,'uint32');
        if (count ~= 1)
          fclose(fid);
          error('roving.Model:unableToLoadROIs', ...
                sprintf('Error loading ROIs from file %s',filename));  %#ok
        end
        %this_border=zeros(2,n_vertices);
        [this_border,count]=fread(fid,[2 n_vertices],'float32');
        %this_border
        if (count ~= 2*n_vertices)
          fclose(fid);
          error('roving.Model:unableToLoadROIs', ...
                sprintf('Error loading ROIs from file %s',filename));  %#ok
        end
        borders{j}=this_border;
      end

      % close the file
      fclose(fid);

      % put the new rois in the model
      self.set_roi(borders,labels);
    end

    % ---------------------------------------------------------------------
    function export_to_tcs_file(self, file_name_abs)
      % calc the ROI means  
      roi_mean = self.mean_over_rois() ;

      % save to .tcs file
      t=self.t;  % s
      roi_label={self.roi.label}';
      roving.write_o_to_tcs(file_name_abs,...
                            t,roi_mean,roi_label);
    end  % method
    
    % ---------------------------------------------------------------------
    function export_rois_to_tiff_file(self, file_name_abs)
      % Make a mask from the ROIs
      n_rows = self.n_rows ;
      n_cols = self.n_cols ;
      mask_image = ...
        roving.roi_list_to_mask_image(self.roi, n_rows, n_cols) ;

      % Save to TIFF file
      imwrite(mask_image, file_name_abs, 'tif') ;
    end  % method
    
    % ---------------------------------------------------------------------
  end  % methods

end  % classdef
