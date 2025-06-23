classdef Model < handle

% This is groundswell_main, a class to represent the underlying data
% in the main window of the groundswell application.

  properties
    t0;
    dt;
    t;  % This property is dependent in spirit, and could be made
        % dependent for real with no change in object semantics.  But we
        % keep it around for speed, because it's used frequently.
        % It's always equal to t0+dt*(0:(size(data,1)-1)' 
    data;  % n_t x n_signals x n_sweeps
    names;
    units;
    filename_abs;  % The filename associated with the data.  An absolute 
                   % path.  Currently all data originates from some file, 
                   % so this will always be set if n_signals>0.
    saved;  % boolean, true if the information in the model is
            % known to be the same as that in filename_abs, false if
            % not.
    file_native;  % Whether the file was loaded from a native file format. 
                  % If true, the file is eligible for saving.  If not, 
                  % file must be saved as a native format.
  end  % properties
  
  properties (Dependent=true)
    fs;  % Hz, sampling rate
    n_t;  % number of time samples
    n_chan;  % number of channels
    tl;  % 2x1 matrix holding min, max time
  end
  
  methods
    function self=Model(t,data,names,units,filename_abs,file_native,saved)
      n_t=size(data,1);
      if n_t==0
        t0=nan;
        dt=nan;
      elseif n_t==1
        t0=t(1);
        dt=nan;
      else
        t0=t(1);
        dt=(t(end)-t0)/(n_t-1);
      end      
      self.t0=t0;
      self.dt=dt;
      self.data=data;
      self.names=names;
      self.units=units;
      self.filename_abs=filename_abs;
      self.saved=saved;
      self.file_native=file_native;
      self.sync_t();
    end  % function
    
    function fs=get.fs(self)
      fs=1/self.dt;
    end
    
    function n_t=get.n_t(self)
      n_t=size(self.data,1);
    end

    function n_chan=get.n_chan(self)
      n_chan=size(self.data,2);
    end

    function tl=get.tl(self)
      t0=self.t0;
      dt=self.dt;
      data=self.data;
      n_t=size(data,1);
      if n_t==0
        tl=[];
      else
        tl=t0+[0 dt*(n_t-1)];
      end
    end
    
    function set.dt(self,dt)
      self.dt=dt;
      self.sync_t();
    end
    
    function sync_t(self)
      t0=self.t0;
      dt=self.dt;
      n_t=size(self.data,1);
      self.t=t0+dt*(0:(n_t-1))';
    end

    function set.fs(self,fs)
      self.dt=1/fs;
      self.sync_t();
    end
    
    function center(self,i_to_change)
      % i_to_change can be a vector
      % center the selected signals
      n_t=size(self.data,1);
      for i=i_to_change
        self.data(:,i,:)=self.data(:,i,:)-...
          repmat(mean(self.data(:,i,:),1),[n_t 1 1]);
      end
      self.saved=false;
    end

    function rectify(self,i_to_change)
      % i_to_change can be a vector
      % rectify the selected signals
      for i=i_to_change
        self.data(:,i,:)=abs(self.data(:,i,:));
      end
      self.saved=false;
    end  % function

    function dx_over_x(self,i_to_change)
      % i_to_change can be a vector
      % Subtract that time-average of each signal from the signal, then
      % divide out the absolute value of the time-average, then convert 
      % to a percentage.
      for i=i_to_change
        d_mean=mean(self.data(:,i,:),1);
        self.data(:,i,:)=bsxfun(@rdivide,self.data(:,i,:),abs(d_mean));
        self.data(:,i,:)=100*(self.data(:,i,:)-sign(d_mean));
        self.units{i}='%';
      end
      self.saved=false;
    end  % function
    
    function saved_as(self,filename_abs)
      self.filename_abs=filename_abs;
      self.saved=true;
      self.file_native=true;
    end

  end  % methods

end  % classdef
