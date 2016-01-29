function out = alignRBR(in,vars,nscan)

% Align the sensor data by advancing or lagging by a user-defined
% number of scans.  A positive scan shift advances the variable in
% time, whereas a negative value delays the value.  The scans at the
% beginning/end of the array are padded with NaNs.
%
%
% At the moment it only lags the sensor(s).
%
%  out = alignRBR(in,vars,nscan)
%
%   where:
%     in         : structure of rbr data (ie output from rbrExtractVals.m)
%     vars       : cell array of variables to filter.
%     nscan      : number of (integer) scans
%
%   Most common use is to shift Temperature and/or Conductivity relative to 
%   Pressure.  Pressure and Temperature are (physically) close together, and 
%   thus matched closely in time.  Water sample is sensed by Conductivity
%   before Pressure and Temperature.
%   
%   Typical delay of C relative to T and P is -2 scans.
%
%   Mark Halverson 
%   29 Dec 2015 V0.9
%   28 Jan 2016 V1.0

if nscan~=fix(nscan),
    error('Number of scans must be an integer.')
end


if ischar(vars),

    fnames = {vars};
    
else
    
    fnames = vars;
    
end


out = in;

for k=1:length(fnames),
    
    if nscan<0,  % delay

        nscan = abs(nscan);
        out.(fnames{k}) = cat(1,NaN(nscan,1),in.(fnames{k})(1:end-nscan));
    
    elseif nscan>0, % advance
        
        out.(fnames{k}) = cat(1,in.(fnames{k})(nscan:end),NaN(nscan,1));
    
    end
    
end



nlog = length(out.processingLog);
out.processingLog(nlog+1) = {[vars ' shifted by ' num2str(nscan) ' scans relative to Pressure']};

