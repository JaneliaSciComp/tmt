classdef Controller < handle
% This is Controller, a class to represent the 
% controller for the main window of the groundswell application.

properties
  model;
  view;
  fs_str;  % string holding the sampling rate, in Hz
%   command_depressed;  % boolean, whether any mac command keys are depressed
%                       % undefined if not running on a macs
end  % properties

methods
  function self=Controller(varargin)
    self.fs_str='';
    self.model=[];
    self.view=groundswell.View(self);
%    self.command_depressed=false;  % probably
    % load the data, if given an arg
    if nargin==1 && ischar(varargin{1})
      filename=varargin{1};
      [~,~,ext]=fileparts(filename);
      if strcmp(ext,'.tcs')
        self.open(filename);
      else
        self.import(filename);
      end
    end
  end  % constructor
  function center(self)
    self.model.center(self.view.i_selected);
    self.view.traces_changed();
  end 
  function rectify(self)
    self.model.rectify(self.view.i_selected);
    self.view.traces_changed();
  end
  function dx_over_x(self)
    self.model.dx_over_x(self.view.i_selected);
    % update the view
    self.view.traces_changed();
    self.view.units_changed();
    % go ahead and re-optimize the y ranges of the modified traces, 
    % because they've almost certainly moved out-of-range
    self.optimize_selected_y_axis_ranges();  % re-optimize range.
  end
end  % methods
  
end  % classdef
