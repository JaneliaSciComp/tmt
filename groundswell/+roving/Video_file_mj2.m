classdef Video_file_mj2 < handle
    
    properties
        vr_  % the VideoReader object
    end  % properties
        
    methods
        function self=Video_file_mj2(file_name)
            self.vr_ = VideoReader(file_name) ;
        end  % constructor method
        
        function delete(self)
            self.vr_=[] ;
        end
        
        function result = bits_per_pel(self)
            result = get(self.vr_,'BitsPerPixel') ;
        end
        
        function result = n_row(self)
            result = get(self.vr_,'Width') ;
        end
        
        function result = n_col(self)
            result = get(self.vr_,'Height') ;
        end
        
        function result = n_frame(self)
            result = get(self.vr_,'NumberOfFrames') ;
        end

        function result = rate(self)
            result = get(self.vr_,'FrameRate') ;
        end
        
        function frame=get_frame(self,i_frame)
            frame=self.vr_.read(i_frame) ;
        end
        
        function frame=get_next(self, i_last_frame_read)
            % Gets frame *after* i_last_frame_read
            frame=self.vr_.read(i_last_frame_read+1);
        end        
        
        function to_start(self) %#ok<MANU>
        end
        
    end  % methods
    
end  % classdef
