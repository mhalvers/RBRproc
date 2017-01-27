function out = alignRBR(in,vars,tShift)

% Advance or lag sensor in time by a user-defined number of seconds.
% A positive value advances the variable in time, whereas a negative
% value delays the variable.  The scans at the beginning/end of the
% array are padded with NaNs.  Advance time is translated into the
% equivalent number of integer scans using the instrument sampling
% period.  Shifting by a fraction of a scan is not supported at this
% time.
%
% Usage:
%
%  out = alignRBR(in,vars,tShift)
%
%   where:
%     in         : structure of rbr data created by output from 
%                  rbrExtractVals.m
%     vars       : cell array of strings describing which variables 
%                  to filter
%     tShift     : time shift in seconds
%
% Most common use is to shift temperature and/or conductivity relative
% to pressure.  The pressure and temperature are (physically) close
% together, and thus matched closely in time.  
%
% In most (?) RBR profilers, a water sample is sampled by the
% conductivity sensor before the pressure and temperature sensors.
% Thus conductivity must be delayed relative to temperature and
% pressure.  The typical delay of conductivity relative to temperature
% and pressure for a 6 Hz profiler is -0.3 seconds, or -2 scans.


% translate from time to scans

if strcmp(class(in.samplingPeriod),'duration')
  dt = seconds(in.samplingPeriod);
else
  dt = in.samplingPeriod;
end

nscan = round(tShift./dt);



out = in;

if ischar(vars),
    vars = cellstr(vars);
end

for k=1:length(vars),
    
    if nscan<0,  % delay

        nscan = abs(nscan);
        out.(vars{k}) = cat(1,NaN(nscan,1),in.(vars{k})(1:end-nscan));
    
    elseif nscan>0, % advance
        
        out.(vars{k}) = cat(1,in.(vars{k})(nscan+1:end),NaN(nscan,1));
    
    end
    
end



%% append processing log


if isfield(in,'processingLog');
  nlog = length(in.processingLog);
else
  nlog = 0;
end

% cat the variables aligned for the log string
if numel(vars)>1,
    vars = strjoin(vars,', ');
end

out.processingLog(nlog+1) = {[char(vars) ' shifted by ' num2str(round(100*tShift)/100) ' seconds']};

