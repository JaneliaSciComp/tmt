classdef Controller < handle

  properties
    model;  % the model
    view;  % the view
    card_birth_roi_next;  % the cardinality of the next ROI to be created
                          % e.g. if the next one will be the 1st one, this 
                          % would be one    
    %shift_depressed;  % boolean, whether any shift keys are depressed                      
  end  % properties
  
  properties (Dependent=true)
    roi_list
  end
  
  methods
    function self=Controller(varargin)
      % Leave the model empty until we load data
      self.model=roving.Model();
      
      % Make the view
      self.view=roving.View(self,self.model);

      % Init the ROI counter, etc.
      self.card_birth_roi_next=[];
      %self.shift_depressed=false;  % probably
      
      % load the data, if given an arg
      if nargin>=1
        if ischar(varargin{1})
          file_name=varargin{1};
          self.open_video_given_file_name(file_name);
        end
      end
    end  % constructor
        
  end  % methods

  methods (Access=private)
  end  % methods
  
end  % classdef
