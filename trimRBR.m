function [out,ind] = trimRBR(in,ind);

% trimRBR discards scans from an RBR profile.  
%
%  usage: out = trimRBR(in,ind);
%
%   where:
%      in          : Structure of RBR profiler data (i.e., 
%                    output from rbrExtractVals.m).
%      ind         : Optional vector of indices to retain.  
%
%      If 'ind' is not specified, trimRBR launches a (crude)
%      interactive plot of pressure vs time so that the user can
%      select the cast limits by hand.  The resulting indices are
%      provided as an optional output.


out = in;

if nargin==1,
    
    figure
    plot(in.Pressure,'ko-')    
    grid on;
  
    disp('Press any key after zooming to choose profile start')
    zoom on;
    pause
    disp('Choose start point')
    [xs,~] = ginput(1);
    clf
  
    plot(in.Pressure,'ko-')    
    grid on;
    zoom on
    disp('Press any key after zooming to choose profile end')
    pause
    disp('Choose end point')
    [xe,~] = ginput(1);
        
elseif nargin==2,

    xs = ind(1);
    xe = ind(end);
    
end



ind = [floor(xs):ceil(xe)];

vars = fieldnames(in);

for j = 1:length(vars)
    if isnumeric(in.(vars{j})) & numel(in.(vars{j}))>1,
        out.(vars{j}) = in.(vars{j})(ind);
    end
end



%% append processing log

if isfield(in,'processingLog');
  nlog = length(in.processingLog);
else
  nlog = 0;
end


out.processingLog(nlog+1) = {['Profile trimmed']};


