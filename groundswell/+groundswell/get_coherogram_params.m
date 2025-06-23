function retval=get_coherogram_params(tl,dt)

% tl is for the view, not the data

% get duration of the view, other things
T_view=tl(2)-tl(1);
fs=1/dt;  % s

% throw up the dialog box
param_str=inputdlg({ 'Window duration (s):' , ...
                     'Steps per window duration:', ...
                     'Time-bandwidth product (NW):' , ...
                     'Number of tapers:' , ...
                     'Maximum frequency (Hz):' ,...
                     'Extra FFT powers of 2:' , ...
                     'Alpha of threshold:' },...
                     'Coherogram parameters...',...
                   1,...
                   { sprintf('%0.3f',T_view/10 ) , ...
                     '10' , ...
                     '4' , ...
                     '7' , ...
                     sprintf('%0.3f',fs/2) , ...
                     '2' , ...
                     '0.05'},...
                   'off');
if isempty(param_str)
  retval=struct([]);
  return;
end

% break out the returned cell array
T_window_want_str=param_str{1};
n_steps_per_window_want_str=param_str{2};
NW_str=param_str{3};
K_str=param_str{4};
f_max_keep_str=param_str{5};
p_FFT_extra_str=param_str{6};
alpha_thresh_str=param_str{7};

%
% convert strings to numbers, and do sanity checks
%

% T_window_want
T_window_want=str2double(T_window_want_str);
if isempty(T_window_want)
  errordlg('Window duration not valid','Error');
  retval=struct([]);
  return;
end
if T_window_want<=0
  errordlg('Window duration must be >= 0','Error');
  retval=struct([]);
  return;
end
T_view=tl(2)-tl(1);
if T_window_want>T_view
  errordlg(sprintf(['Window duration must be less than the view ' ...
                    'duration (%0.3f s)'],T_view),...
           'Error');
  retval=struct([]);
  return;
end

% n_steps_per_window_want
n_steps_per_window_want=str2double(n_steps_per_window_want_str);
if isempty(n_steps_per_window_want)
  errordlg('Number of windows not valid','Error');
  retval=struct([]);
  return;
end
if n_steps_per_window_want~=round(n_steps_per_window_want)
  errordlg('Number of steps per window must be an integer','Error');
  retval=struct([]);
  return;
end
if n_steps_per_window_want<1
  errordlg('Number of steps per window must be >= 1','Error');
  retval=struct([]);
  return;
end

% NW
NW=str2double(NW_str);
if isempty(NW)
  errordlg('Time-bandwidth product (NW) not valid','Error');
  retval=struct([]);
  return;
end
if NW<1
  errordlg('Time-bandwidth product (NW) must be >= 1','Error');
  retval=struct([]);
  return;
end

% K
K=str2double(K_str);
if isempty(K)
  errordlg('Number of tapers not valid','Error');
  retval=struct([]);
  return;
end
if K~=round(K)
  errordlg('Number of tapers must be an integer','Error');
  retval=struct([]);
  return;
end
if K>2*NW-1
  errordlg('Number of tapers must be <= 2*NW-1','Error');
  retval=struct([]);
  return;
end

% f_max_keep
f_max_keep=str2double(f_max_keep_str);
if isempty(f_max_keep)
  errordlg('Maximum frequency not valid','Error');
  retval=struct([]);
  return;
end
if f_max_keep<0
  errordlg('Maximum frequency must be >= 0','Error');
  retval=struct([]);
  return;
end
if f_max_keep>fs/2
  errordlg(sprintf(['Maximum frequency must be <= half the ' ...
                    'sampling frequency (%0.3f Hz)'],fs),...
           'Error');
  retval=struct([]);
  return;
end

% p_FFT_extra
p_FFT_extra=str2double(p_FFT_extra_str);
if isempty(p_FFT_extra)
  errordlg('Extra FFT powers of 2 not valid','Error');
  retval=struct([]);
  return;
end
if p_FFT_extra~=round(p_FFT_extra)
  errordlg('Extra FFT powers of 2 must be an integer','Error');
  retval=struct([]);
  return;
end
if p_FFT_extra<0
  errordlg('Extra FFT powers of 2 must be >= 0','Error');
  retval=struct([]);
  return;
end

% alpha_thresh
alpha_thresh=str2double(alpha_thresh_str);
if isempty(alpha_thresh)
  errordlg('Alpha of threshold not valid','Error');
  retval=struct([]);
  return;
end
if alpha_thresh<0
  errordlg('Alpha of threshold must be >= 0','Error');
  retval=struct([]);
  return;
end
if alpha_thresh>1
  errordlg('Alpha of threshold must be <= 1',...
           'Error');
  retval=struct([]);
  return;
end

% package into structure
retval=struct('T_window_want',T_window_want,...
              'n_steps_per_window_want',n_steps_per_window_want,...
              'NW',NW,...
              'K',K,...
              'f_max_keep',f_max_keep,...
              'p_FFT_extra',p_FFT_extra,...
              'alpha_thresh',alpha_thresh);
