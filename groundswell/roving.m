function varargout=roving(varargin)

% create the Controller instance
rc=roving.Controller(varargin{:});

if nargout>=1
  varargout{1}=rc;
end

end
