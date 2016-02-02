function [out] = filterRBR(in,vars,np)

% filterRBR applies FIR low-pass filter to sensor data
%
%  usage: out = filterRBR(in,vars,np);
%
%   where:
%      in          : structure of rbr data (ie output from rbrExtractVals.m)
%      vars        : cell array of variables to filter. 'all' for all sensors 
%      np          : filter parameter
%
%     If 'np' is a scalar, specifies the length of a triangular window
%     If 'np' is a vector, then this is the window applied to the data
%     - eg hamming(21)/sum(hamming(21))
%
%     note - filterRBR is configured to use filtfilt to produce a
%     zero-phase response.  Should probably include the option to call
%     filter to produce phase shifted output (useful for matching
%     sensor time constants?).

%% set up filter

if numel(np)==1,

    fltr = triang(np)/sum(triang(np));fltr = fltr(:);
    
else
    
    fltr = np(:);
    
end


out = in;

for k=1:length(vars),

    out.(vars{k}) = filtfilt(fltr,1,in.(vars{k}));

end



% IIR butterworth
% [b,a] = butter(1,.5); % 1st order, 3 Hz cutoff (Wn = 3/6*2pi)
% freqz(b,a)
% fcon2 = filtfilt(b,a,con);


out.processingLog = {[vars ' filtered with '...
                     num2str(np) ' point triangular window']};


