function [out] = filterRBR(in,vars,np)

% filterRBR applies FIR low-pass filter to sensor data
%
%  usage: out = filterRBR(in,vars,np);
%
%   where:
%      in          : structure of rbr data (ie output from rbrExtractVals.m)
%      vars        : cell array of variables to filter
%      np          : filter length in points
%
%     If 'np' is a scalar, specifies the length (in points) of a
%     triangular window.  If 'np' is a vector, then it is taken to be
%     the window function to be applied to the data - eg
%     hamming(21)/sum(hamming(21)).
%
%     filterRBR uses the Matlab Signal Processing Toolbox function
%     'filtfilt'
%
%     Note - filtfilt produces a zero-phase response.  One might
%     choose to call filter with a IIR-type filter to match sensor
%     time constants.  However, the lag produced by a sensor's
%     time-dependent response can be accounted for by simply shifting
%     the sensor in time (eg, with 'alignRBR')


% check if Signal Processing toolbox exists
v = ver;

if ~any(strcmp('Signal Processing Toolbox', {v.Name})),
    error('filterRBR requires Signal Process Toolbox function ''filtfilt''')
end


%% set up filter

if numel(np)==1,

    fltr = triang(np)/sum(triang(np));fltr = fltr(:);
    
else
    
    fltr = np(:);
    
end


out = in;

if ischar(vars),
  vars = cellstr(vars);    
end


for k=1:length(vars),
    
   fvar = in.(vars{k});

   % NaN handling
    
    kk = isfinite(fvar);
    nvar = NaN(size(fvar));
    
    % apply the filter
    nvar(kk) = filtfilt(fltr,1,fvar(kk));
   
    out.(vars{k}) = nvar;

end


%% set up processing log text

if numel(vars)>1,
    vars = strjoin(vars,', ');
end
if numel(np)==1,
    wdw = 'triangle';
else
    wdw = 'custom';
    np = length(np);
end


%% append processing log

if isfield(in,'processingLog');
  nlog = length(in.processingLog);
else
  nlog = 0;
end

out.processingLog(nlog+1) = {[char(vars) ' filtered with '...
                              num2str(np) ' point ' wdw ' window']};


