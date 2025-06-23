classdef Overlay_file_reader < handle

  properties
    fid;
    index;
  end  % properties
  
  properties (Dependent=true)
    n_frames;
  end
  
  methods
    function self=Overlay_file_reader(file_name)
      self.fid=fopen(file_name,'rb','ieee-le','ISO-8859-1');
      if self.fid<0
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_reader.unable_to_open_file', ...
              'Unable to open file %s',file_name);  %#ok
      end
      % check that the header is there
      header=fread(self.fid,[1 8],'*char');
      if ~strcmp(header,'ovl00001')
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_reader.wrong_header', ...
              'File %s doesn''t have the right header for a .ovl file', ...
              file_name);  %#ok
      end
      % read the number of frames
      [n_frames,count]=fread(self.fid,1,'*uint64');
      if count~=1
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_reader.unable_to_read_n_frames', ...
              'Unable to read the number of frames in %s', ...
              file_name);  %#ok
      end
      % read the index
      [self.index,count]=fread(self.fid,n_frames,'*uint64');
      if count~=n_frames
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_reader.unable_to_read_index', ...
              'Unable to read the frame index in %s', ...
              file_name);  %#ok
      end
    end  % function

    function n_frames=get.n_frames(self)
      n_frames=length(self.index);
    end
    
    function frame_overlay=read_frame_overlay(self,i_frame)
      n_frames=length(self.index);
      if (1<=i_frame) && (i_frame<=n_frames)
        offset=self.index(i_frame);
        status=fseek(self.fid,double(offset),'bof');
          % in r2012a on mac, fseek() returns -1 if you give it a uint64
          % file offset...
        if status<0
          error('Overlay_file_reader.unable_to_seek_to_frame_start', ...
                'Unable to seek to frame start in .ovl file');  %#ok
        end
        frame_overlay=self.read_frame_overlay_raw();
      else
        error('Overlay_file_reader.invalid_frame_index', ...
              'Invalid frame index to .ovl file');  %#ok
      end
    end
    
    function close(self)
      fclose(self.fid);
      self.fid=[];
      self.index=[];
    end
    
    function delete(self)
      % called when being GC'ed
      if ~isempty(self.fid)
        fclose(self.fid);
      end
    end      
  end  % methods

  methods (Access=private)
    function frame_overlay=read_frame_overlay_raw(self)
      % reads the frame at the current file pointer location
      % check that the header is there
      [header,count]=fread(self.fid,[1 8],'*char');
      if count~=8 || ~strcmp(header,'frame---')
        self.close();
        error('Overlay_file_reader.invalid_frame_header', ...
              'Invalid frame header in .ovl file');  %#ok
      end
      % read the number of objects in the frame
      [n_objects,count]=fread(self.fid,1,'*uint64');
      if count~=1
        self.close();
        error('Overlay_file_reader.unable_to_read_n_objects', ...
              'Unable to read number of objects in frame');  %#ok
      end
      frame_overlay=cell(n_objects,1);
      for i=1:n_objects
        frame_overlay{i}=self.read_overlay_object();
      end
    end
    
    function obj=read_overlay_object(self)
      % reads the object at the current file pointer location
      % check that the header is there
      [header,count]=fread(self.fid,[1 8],'*char');
      if count~=8
        self.close();
        error('Overlay_file_reader.unable_to_read_object_header', ...
              'Unable to read an object header in .ovl file');  %#ok
      end
      % dispatch on header
      if strcmp(header,'line----')
        % line object
        obj=self.read_line_overlay();
      elseif strcmp(header,'text----')
        % text object
        obj=self.read_text_overlay();        
      else
        % WTF?
        self.close();
        error('Overlay_file_reader.invalid_object_type', ...
              'Invalid object type in .ovl file');  %#ok
      end
    end
    
    function lin=read_line_overlay(self)
      % reads the line object at the current file pointer location
      % assumes the single-letter object header has already been read
      % read the line width
      [width,count]=fread(self.fid,1,'*double');
      if count~=1
        self.close();
        error('Overlay_file_reader.unable_to_read_line_width', ...
              'Unable to read line width in .ovl file');  %#ok
      end
      % read the color
      [clr,count]=fread(self.fid,[1 3],'*double');
      if count~=3
        self.close();
        error('Overlay_file_reader.unable_to_read_line_color', ...
              'Unable to read line color in .ovl file');  %#ok
      end
      % read the number of vertices in the line
      [n_vertices,count]=fread(self.fid,1,'*uint64');
      if count~=1
        self.close();
        error('Overlay_file_reader.unable_to_read_n_vertices', ...
              'Unable to read number of vertices in line in .ovl file');  %#ok
      end
      % read the x-coords
      [x,count]=fread(self.fid,[n_vertices 1],'*double');
      if count~=n_vertices
        self.close();
        error('Overlay_file_reader.unable_to_read_line_x_coords', ...
              'Unable to read x-coordinates of line in .ovl file');  %#ok
      end
      % read the y-coords
      [y,count]=fread(self.fid,[n_vertices 1],'*double');
      if count~=n_vertices
        self.close();
        error('Overlay_file_reader.unable_to_read_line_y_coords', ...
              'Unable to read y-coordinates of line in .ovl file');  %#ok
      end
      % package stuff up
      lin=roving.Line_overlay(x,y,width,clr);
    end    
      
    function txt=read_text_overlay(self)
      % reads the text object at the current file pointer location
      % assumes the single-letter object header has already been read
      % read the font size, in pixels, assuming a 72 ppi monitor
      [sz,count]=fread(self.fid,1,'*double');
      if count~=1
        self.close();
        error('Overlay_file_reader.unable_to_read_text_font_size', ...
              'Unable to read text font size in .ovl file');  %#ok
      end
      % read the color
      [clr,count]=fread(self.fid,[1 3],'*double');
      if count~=3
        self.close();
        error('Overlay_file_reader.unable_to_read_text_color', ...
              'Unable to read text color in .ovl file');  %#ok
      end
      % read the x-coord
      [x,count]=fread(self.fid,1,'*double');
      if count~=1
        self.close();
        error('Overlay_file_reader.unable_to_read_text_x_coord', ...
              'Unable to read x-coordinate of text in .ovl file');  %#ok
      end
      % read the y-coord
      [y,count]=fread(self.fid,1,'*double');
      if count~=1
        self.close();
        error('Overlay_file_reader.unable_to_read_text_y_coord', ...
              'Unable to read y-coordinate of text in .ovl file');  %#ok
      end
      % read the number of chars in the line
      [n_chars,count]=fread(self.fid,1,'*uint64');
      if count~=1
        self.close();
        error('Overlay_file_reader.unable_to_read_n_chars', ...
              'Unable to read number of chars in text in .ovl file');  %#ok
      end
      % read the string
      [str,count]=fread(self.fid,[1 n_chars],'uchar=>char');
      if count~=n_chars
        self.close();
        error('Overlay_file_reader.unable_to_read_string', ...
              'Unable to read string in text in .ovl file');  %#ok
      end
      % package stuff up
      txt=roving.Text_overlay(x,y,str,clr,sz);
    end    
    
  end  % private methods
  
end  % classdef
