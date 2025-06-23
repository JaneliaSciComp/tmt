classdef Overlay_file_writer < handle
  
  properties
    file_header='ovl00001';
    fid;
    index;
    n_frames_written;
  end  % properties
  
  properties (Dependent=true)
  end
  
  methods
    function self=Overlay_file_writer(file_name,n_frames)
      self.fid=fopen(file_name,'wb','ieee-le','ISO-8859-1');
      if self.fid<0
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_open_file', ...
              'Unable to open file %s',file_name);  %#ok
      end
      % write the header
      header=self.file_header;
      count=fwrite(self.fid,header,'char');
      if count~=length(header)
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_header', ...
              'Unable to write the header to file %s', ...
              file_name);  %#ok
      end
      % write the number of frames
      count=fwrite(self.fid,n_frames,'uint64');
      if count~=1
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_n_frames', ...
              'Unable to write the number of frames in %s', ...
              file_name);  %#ok
      end
      % write an empty index
      self.index=zeros(n_frames,1,'uint64');
      count=fwrite(self.fid,self.index,'uint64');
      if count~=n_frames
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_empty_index', ...
              'Unable to write the empty index in %s', ...
              file_name);  %#ok
      end
      self.n_frames_written=uint64(0);
    end  % function

    function append_frame_overlay(self,frame_overlay)
      % write the current file position to the index
      file_offset=ftell(self.fid);
      if file_offset>=0
        self.index(self.n_frames_written+1)=ftell(self.fid);
      else
        close(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_get_file_offset', ...
              'Unable to get file offset while writing frame overlay');  %#ok
      end        

      % write the frame overlay to the file
      % write the header
      header='frame---';
      count=fwrite(self.fid,header,'char');
      if count~=length(header)
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_header', ...
              'Unable to write a frame header to .ovl file', ...
              file_name);  %#ok
      end
      n_objects=length(frame_overlay);
      count=fwrite(self.fid,n_objects,'uint64');
      if count~=1
        close(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_n_objects', ...
              'Unable to write number of objects in frame');  %#ok
      end      
      for i=1:n_objects
        self.append_overlay_object(frame_overlay{i});
      end
      
      % update the number of frames written
      self.n_frames_written=self.n_frames_written+1;
    end
    
    function close(self)
      if ~isempty(self.fid)
        % write the in-memory index to disk
        fseek(self.fid,length(self.file_header)+8,'bof');
        n_frames=length(self.index);
        count=fwrite(self.fid,self.index,'uint64');
        if count~=n_frames
          fclose(self.fid);
          self.fid=[];
          error('Overlay_file_writer.unable_to_write_index', ...
                'Unable to write the index');  %#ok
        end
        % close the file
        fclose(self.fid);
        self.fid=[];
        self.index=[];
      end
    end
    
    function delete(self)
      % called when being GC'ed
      if ~isempty(self.fid)
        fclose(self.fid);
      end
    end      
  end  % methods

  methods (Access=private)
    function append_overlay_object(self,obj)
      % writes the object at the current file pointer location

      % write the 
      if isobject(obj)
        if isa(obj,'roving.Line_overlay')
          self.append_line_object(obj);
        elseif isa(obj,'roving.Text_overlay')
          self.append_text_object(obj);
        else
          fclose(self.fid);
          self.fid=[];
          error('Overlay_file_writer.overlay_object_not_valid', ...
                'Unable to write invalid overlay object to .ovl file');  %#ok
        end
      else
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.overlay_object_not_object', ...
              'Unable to write non-object overlay object to .ovl file');  %#ok
      end
    end
    
    function append_line_object(self,lin)
      % writes the line object at the current file pointer location
      % write the header
      header='line----';
      count=fwrite(self.fid,header,'char');
      if count~=length(header)
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_line_header', ...
              'Unable to write the header for a line object to .ovl file');  %#ok
      end
      % write the line width, in pixels, assuming a 72 ppi monitor
      count=fwrite(self.fid,lin.width,'double');
      if count~=1
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_line_width', ...
              'Unable to write line width to .ovl file');  %#ok
      end
      % write the color
      count=fwrite(self.fid,lin.color,'double');
      if count~=3
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_line_color', ...
              'Unable to write line color to .ovl file');  %#ok
      end
      % write the number of vertices in the line
      n_vertices=uint64(length(lin.x));
      count=fwrite(self.fid,n_vertices,'uint64');
      if count~=1
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_n_vertices', ...
              'Unable to write number of vertices in line in .ovl file');  %#ok
      end
      % write the x-coords
      count=fwrite(self.fid,lin.x,'double');
      if count~=n_vertices
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_line_x_coords', ...
              'Unable to write x-coordinates of line to .ovl file');  %#ok
      end
      % write the y-coords
      count=fwrite(self.fid,lin.y,'double');
      if count~=n_vertices
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_line_y_coords', ...
              'Unable to write y-coordinates of line to .ovl file');  %#ok
      end
    end    
      
    function append_text_object(self,txt)
      % writes the text object at the current file pointer location
      header='text----';
      count=fwrite(self.fid,header,'char');
      if count~=length(header)
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_text_header', ...
              'Unable to write the header for a text object to .ovl file');  %#ok
      end
      % write the text size, in pixels, assuming a 72 ppi monitor
      count=fwrite(self.fid,txt.size,'double');
      if count~=1
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_text_color', ...
              'Unable to write text size to .ovl file');  %#ok
      end
      % write the color
      count=fwrite(self.fid,txt.color,'double');
      if count~=3
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_text_color', ...
              'Unable to write text color to .ovl file');  %#ok
      end
      % write the x-coord
      count=fwrite(self.fid,txt.x,'double');
      if count~=1
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_text_x_coord', ...
              'Unable to write x-coordinate of text to .ovl file');  %#ok
      end
      % write the y-coords
      count=fwrite(self.fid,txt.y,'double');
      if count~=1
        fclose(self.fid);
        self.fid=[];
        error('Overlay_file_writer.unable_to_write_text_y_coord', ...
              'Unable to write y-coordinate of text to .ovl file');  %#ok
      end
      % write the number of chars in the text
      n_chars=uint64(length(txt.string));
      count=fwrite(self.fid,n_chars,'uint64');
      if count~=1
        self.close();
        error('Overlay_file_writer.unable_to_write_n_chars', ...
              'Unable to write number of chars in text to .ovl file');  %#ok
      end
      % write the string
      count=fwrite(self.fid,txt.string,'char');
      if count~=n_chars
        self.close();
        error('Overlay_file_writer.unable_to_write_string', ...
              'Unable to write text string to .ovl file');  %#ok
      end
    end    
    
  end  % private methods
  
end  % classdef
