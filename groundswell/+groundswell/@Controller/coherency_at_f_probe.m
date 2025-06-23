function coherency_at_f_probe(self)

% get stuff we'll need
i_selected=self.view.i_selected;
t=self.model.t;
data=self.model.data;
names=self.model.names;

% are there at least two signals selected?
n_selected=length(i_selected);
if n_selected<2
  errordlg('Can only calculate coherency between two or more signals.',...
           'Error');
  return;
end

% get indices of signals
i_y=i_selected(1:end-1);  % the non-pivots are the test signals
i_x=i_selected(end);  % the pivot is the reference signal
n_y=length(i_y);

% sort the test signals, b/c we want them in the same order as displayed,
% not whatever random order they were selected in.
i_y=sort(i_y);

% extract the data we need
n_t=length(t);
n_sweeps=size(data,3);
x=reshape(data(:,i_x,:),[n_t n_sweeps]);
name_x=names{i_x};
%units_x=units{i_x};
y_all=permute(reshape(data(:,i_y,:),[n_t n_y n_sweeps]),[1 3 2]);
name_y=names(i_y);  % cell array, n_y x 1
%units_y=units{i_y};
clear data;

% calc sampling rate
dt=(t(end)-t(1))/(length(t)-1);
fs=1/dt;

% throw up the dialog box
param_str=inputdlg({ 'Number of windows:' , ...
                     'Time-bandwidth product (NW):' , ...
                     'Number of tapers:' , ...
                     'Probe frequency (Hz):' ,...
                     'Extra FFT powers of 2:' , ...
                     'Confidence level:' , ...
                     'Alpha of threshold:' },...
                     'Coherency parameters...',...
                   1,...
                   { '1' , ...
                     '4' , ...
                     '7' , ...
                     sprintf('%0.3f',fs/4) , ...
                     '2' , ...
                     '0.95' ,...
                     '0.05' },...
                   'off');
if isempty(param_str)
  return;
end

% break out the returned cell array
n_windows_str=param_str{1};
NW_str=param_str{2};
K_str=param_str{3};
f_probe_str=param_str{4};
p_FFT_extra_str=param_str{5};
conf_level_str=param_str{6};
alpha_thresh_str=param_str{7};

%
% convert strings to numbers, and do sanity checks
%

% n_windows
n_windows=str2double(n_windows_str);
if isempty(n_windows)
  errordlg('Number of windows not valid','Error');
  return;
end
if n_windows~=round(n_windows)
  errordlg('Number of windows must be an integer','Error');
  return;
end
if n_windows<1
  errordlg('Number of windows must be >= 1','Error');
  return;
end

% NW
NW=str2double(NW_str);
if isempty(NW)
  errordlg('Time-bandwidth product (NW) not valid','Error');
  return;
end
if NW<1
  errordlg('Time-bandwidth product (NW) must be >= 1','Error');
  return;
end

% K
K=str2double(K_str);
if isempty(K)
  errordlg('Number of tapers not valid','Error');
  return;
end
if K~=round(K)
  errordlg('Number of tapers must be an integer','Error');
  return;
end
if K>2*NW-1
  errordlg('Number of tapers must be <= 2*NW-1','Error');
  return;
end

% f_probe
f_probe=str2double(f_probe_str);
if isempty(f_probe)
  errordlg('Probe frequency not valid','Error');
  return;
end
if f_probe<0
  errordlg('Probe frequency must be >= 0','Error');
  return;
end
if f_probe>fs/2
  errordlg(sprintf(['Probe frequency must be <= half the ' ...
                    'sampling frequency (%0.3f Hz)'],fs),...
           'Error');
  return;
end

% p_FFT_extra
p_FFT_extra=str2double(p_FFT_extra_str);
if isempty(p_FFT_extra)
  errordlg('Extra FFT powers of 2 not valid','Error');
  return;
end
if p_FFT_extra~=round(p_FFT_extra)
  errordlg('Extra FFT powers of 2 must be an integer','Error');
  return;
end
if p_FFT_extra<0
  errordlg('Extra FFT powers of 2 must be >= 0','Error');
  return;
end

% conf_level
conf_level=str2double(conf_level_str);
if isempty(conf_level)
  errordlg('Confidence level not valid','Error');
  return;
end
if conf_level<0
  errordlg('Confidence level must be >= 0','Error');
  return;
end
if conf_level>=1
  errordlg('Confidence level must be < 1',...
           'Error');
  return;
end

% alpha_thresh
alpha_thresh=str2double(alpha_thresh_str);
if isempty(alpha_thresh)
  errordlg('Alpha of threshold not valid','Error');
  return;
end
if alpha_thresh<0
  errordlg('Alpha of threshold must be >= 0','Error');
  return;
end
if alpha_thresh>1
  errordlg('Alpha of threshold must be <= 1',...
           'Error');
  return;
end

%
% all parameters are converted, and are in-bounds
%



%
% do the analysis
%

% may take a while
self.view.hourglass();

%
% get x ready
%

% get just the data in view
tl=self.model.tl;
tl_view=self.view.tl_view;
N=self.model.n_t;
jl=interp1(tl,[1 N],tl_view,'linear','extrap');
jl(1)=floor(jl(1));
jl(2)= ceil(jl(2));
jl(1)=max(1,jl(1));
jl(2)=min(N,jl(2));
x_short=x(jl(1):jl(2),:);
clear t x;
N=size(x_short,1);

% center the data
x_short_mean=mean(x_short,1);
x_short_cent=x_short-repmat(x_short_mean,[N 1]);

% determine window size
N_window=floor(N/n_windows);
%T_window=dt*N_window;

% want N to be integer multiple of N_window
N=N_window*n_windows;
x_short_cent=x_short_cent(1:N,:);

% put windows into the second index
x_short_cent_windowed=...
  reshape(x_short_cent,[N_window n_windows*n_sweeps]);

% figure out the highest frequency we'll need to get f_probe
N_fft=2^(ceil(log2(N_window))+p_FFT_extra);
df=fs/N_fft;
f_max_keep=df*(ceil(f_probe/df)+1);  % +1 just to be sure...

%
% now do stuff for each of the y signals in turn
%
Cyx_mag_probe=zeros(n_y,1);
Cyx_phase_probe=zeros(n_y,1);
Cyx_mag_ci_probe=zeros(n_y,2);
Cyx_phase_ci_probe=zeros(n_y,2);
for k=1:n_y
  y=y_all(:,:,k);

  % get just the data in view
  y_short=y(jl(1):jl(2),:);
  clear y;

  % center the data
  y_short_mean=mean(y_short,1);
  y_short_cent=y_short-repmat(y_short_mean,[N 1]);

  % want N to be integer multiple of N_window
  y_short_cent=y_short_cent(1:N,:);
  %T=dt*N;

  % put windows into the second index
  y_short_cent_windowed=...
    reshape(y_short_cent,[N_window n_windows*n_sweeps]);

  % calc the coherency, using multitaper routine
  [f,Cyx_mag,Cyx_phase,...
   N_fft,W_smear_fw,~,...
   Cyx_mag_ci,Cyx_phase_ci]=...
    coh_mt(dt,y_short_cent_windowed,x_short_cent_windowed,...
           NW,K,f_max_keep,...
           p_FFT_extra,conf_level);

  % interpolate to get C at the probe freq
  Cyx_mag_probe_this=interp1(f,Cyx_mag,f_probe,'*linear');
  Cyx_phase_probe_this=interp1(f,Cyx_phase,f_probe,'*linear');
  Cyx_mag_ci_probe_this=interp1(f,Cyx_mag_ci,f_probe,'*linear');
  Cyx_phase_ci_probe_this=interp1(f,Cyx_phase_ci,f_probe,'*linear');
         
  % store the coherency at the probe freq
  Cyx_mag_probe(k)=Cyx_mag_probe_this;
  Cyx_phase_probe(k)=Cyx_phase_probe_this;
  Cyx_mag_ci_probe(k,:)=Cyx_mag_ci_probe_this;
  Cyx_phase_ci_probe(k,:)=Cyx_phase_ci_probe_this;
end

% calc the significance threshold, quick
R=n_windows*n_sweeps;  % number of samples of each process
%alpha_thresh=0.05;
Cyx_mag_thresh=coh_mt_control_analytical(R,K,alpha_thresh);

% plot coherency at the probe f
if length(name_y)==1
  title_str=sprintf('Coherency of %s relative to %s, at f=%0.3f Hz',...
                    name_y{1},name_x,f_probe);
else
  title_str=sprintf('Coherency of multiple signals relative to %s, at f=%0.3f Hz',...
                    name_x,f_probe);
end  
% h_fig_coh=...
%   figure_coh_polar(Cyx_mag_probe,Cyx_phase_probe,...
%                    Cyx_mag_ci_probe,Cyx_phase_ci_probe,...
%                    (1:n_y)',name_y,...
%                    0,Cyx_mag_thresh,...
%                    1,...
%                    'l75_border_of_r_theta',[0 0 0]);    
clr=self.view.colors(i_y,:);
[h_fig_coh,h_a]=...
  figure_coh_polar(Cyx_mag_probe,Cyx_phase_probe,...
                   Cyx_mag_ci_probe,Cyx_phase_ci_probe,...
                   name_y,...
                   0,Cyx_mag_thresh,...
                   1,...
                   clr,[0 0 0]);    
set(h_fig_coh,'name',title_str);
set(h_fig_coh,'color','w');
text(0.98,0.98,sprintf('W_smear_fw: %0.3f Hz\nN_fft: %d',W_smear_fw,N_fft),...
     'parent',h_a,...
     'units','normalized',...
     'horizontalalignment','right',...
     'verticalalignment','top',...
     'interpreter','none');
drawnow('update');
drawnow('expose');

% put data on clipboard
txt_clipboard=sprintf('Number of windows: %d\n',n_windows);
txt_clipboard=[txt_clipboard ...
               sprintf('Time-bandwidth product (NW): %g\n',NW)];
txt_clipboard=[txt_clipboard ...
               sprintf('Number of tapers (K): %d\n',K)];
txt_clipboard=[txt_clipboard ...
               sprintf('Probe frequency: %g Hz\n',f_probe)];
txt_clipboard=[txt_clipboard ...
               sprintf('Extra powers of 2 in FFT: %d\n',p_FFT_extra)];
txt_clipboard=[txt_clipboard ...
               sprintf('Confidence interval coverage: %g\n',conf_level)];
txt_clipboard=[txt_clipboard ...
               sprintf(['Alpha for coherence magnitude significance ' ...
                        'threshold: %g\n'], ...
                       alpha_thresh)];
txt_clipboard=[txt_clipboard sprintf('\n')];
txt_clipboard=[txt_clipboard ...
               sprintf('Smearing bandwidth (full-width): %0.3g Hz\n', ...
                       W_smear_fw)];
txt_clipboard=[txt_clipboard ...
               sprintf('Number of points in FFT: %d\n',N_fft)];
txt_clipboard=[txt_clipboard ...
               sprintf(['Coherence magnitude threshold for ' ...
                        'significance: %0.3f\n'], ...
                       Cyx_mag_thresh)];
txt_clipboard=[txt_clipboard sprintf('\n')];               
txt_clipboard= ...
  [txt_clipboard ...
   sprintf('%20s     %13s  %7s  %13s     %15s  %9s  %15s     %12s\n', ...
           'Name', ...
           'Cyx_mag_ci_lo','Cyx_mag','Cyx_mag_ci_hi', ...
           'Cyx_phase_ci_lo','Cyx_phase','Cyx_phase_ci_hi', ...
           'Significant?')];
for k=1:n_y
  if Cyx_mag_probe(k)>Cyx_mag_thresh
    sig_str='y';
  else
    sig_str='n';
  end
  % At one point, Stefan requested that insignificant phases be reported as nan.
  % Backing that change out at the request of one of his lab members.  Hopefully
  % the "n" in the "Significant?" column should make it clear...
  Cyx_phase_ci_lo_probe_disp=180/pi*wrap(Cyx_phase_ci_probe(k,1));
  Cyx_phase_probe_disp=180/pi*wrap(Cyx_phase_probe(k));
  Cyx_phase_ci_hi_probe_disp=180/pi*wrap(Cyx_phase_ci_probe(k,2));
  txt_clipboard= ...
    [txt_clipboard ...
     sprintf(['%20s     %13.3f  %7.3f  %13.3f     ' ...
              '%15.1f  %9.1f  %15.1f     %12s\n'], ...
             name_y{k}, ...
             Cyx_mag_ci_probe(k,1), ...
             Cyx_mag_probe(k), ...
             Cyx_mag_ci_probe(k,2), ...
             Cyx_phase_ci_lo_probe_disp, ...
             Cyx_phase_probe_disp, ...
             Cyx_phase_ci_hi_probe_disp, ...
             sig_str)];  %#ok
end
clipboard('copy',txt_clipboard);

%% put it in a file, also
%file_name='export_from_groundswell.csv';
%fid=fopen(file_name,'wt');
%if fid>0
%  try
%    fprintf(fid,txt_clipboard);
%    fclose(fid);
%  catch err
%    % ignore any errors
%  end
%end

% set pointer back
self.view.unhourglass();

end
