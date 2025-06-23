function quit_requested(self)

% fpj=get(handle(self.fig_h),'JavaFrame');
% jw=fpj.fHG1Client.getWindow;
% jcb=handle(jw,'CallbackProperties');
% set(jcb,'WindowGainedFocusCallback',[]);  % have to do this, or else
%                                           % the MVC objects hang around
% clear fpj jw jcb;

delete(self.fig_h);
self.fig_h=[];

end
