classdef Video_file < handle
    
    properties
        file_type_  % we never read this currently, but probably nice to have around
        typed_video_file_        
        i_frame_  % last frame gotten, 1-based index
    end  % properties
        
    methods
        function self=Video_file(file_name)
            [~,~,ext] = fileparts(file_name) ;
            switch ext ,
                case '.tif' ,
%                     [tiff_struct, tiff_header] = roving.tiffread31_header(file_name) ;
%                     tiff_tags = roving.tiffread31_readtags(tiff_struct, tiff_header, 1) ;
%                     is_imagej_jumbo_tiff = ...
%                         roving.IsImageJBigStack(tiff_tags, numel(tiff_header));
%                     fclose(tiff_struct.file) ;
                    is_file_an_imagej_jumbo_tif = roving.is_file_an_imagej_jumbo_tif(file_name) ;
                    if  is_file_an_imagej_jumbo_tif ,
                        self.file_type_ = 'imagej_jumbo_tif' ;                        
                        self.typed_video_file_ = roving.Video_file_imagej_jumbo_tif(file_name) ;
                    else
                        self.file_type_ = 'tif' ;
                        self.typed_video_file_ = roving.Video_file_normal_tif(file_name) ;
                    end
                case '.mj2' ,
                    self.file_type_ = 'mj2' ;
                    self.typed_video_file_ = roving.Video_file_mj2(file_name) ;
                otherwise
                    error('Video_file:UnableToLoad','Unable to load that file type');
            end
            self.i_frame_ = 0 ;
        end  % constructor method
        
        function delete(self)
            self.typed_video_file_ = [] ;
        end
        
        function result = bits_per_pel(self)
            result = self.typed_video_file_.bits_per_pel() ;
        end
        
        function result = n_row(self)
            result = self.typed_video_file_.n_row() ;
        end
        
        function result = n_col(self)
            result = self.typed_video_file_.n_col() ;
        end
        
        function result = n_frame(self)
            result = self.typed_video_file_.n_frame() ;
        end

        function result = rate(self)
            result = self.typed_video_file_.rate() ;
        end        
        
        function result = dt(self)  % s, 1/rate
            rate = self.rate() ;
            if isempty(rate) ,
                result=[];
            else
                result=1/rate;
            end
        end
        
        function frame=get_frame(self, i)
            frame = self.typed_video_file_.get_frame(i) ;
            self.i_frame_ = i ;
        end
        
        function frame=get_next(self)
            i_frame = self.i_frame_ ;
            frame = self.typed_video_file_.get_next(i_frame) ;
            self.i_frame_ = i_frame + 1 ;
        end
        
        function frame=get_prev(self)
            frame=self.get_frame(self.i_frame_);
        end
        
        function pred=at_end(self)
            pred=(self.i_frame_==self.n_frame());
        end
        
        function pred=at_start(self)
            pred=(self.i_frame_==0);
        end
        
        function to_start(self)
            self.typed_video_file_.to_start() ;
            self.i_frame_=0;
        end
    end  % methods
    
end  % classdef
