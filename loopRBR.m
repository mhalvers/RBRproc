function out = loopRBR(in,replaceWith)
%
% usage: out = loopRBR(in,replaceWith)
%
%
%   where
%     in        : structure of rbr data created by output from
%                 rbrExtractVals.m
%
%    replaceWith : How to treat the flagged values:
%                :   one of 'interp' or 'NaN'
%                :     'interp'   - linear interpolation over flagged values
%                :     'NaN'      - replace flagged values with NaN
%
%
% loopRBR identifies scans for which the data is likely of poor
% quality because of slow descent rates and decelaration.  In such
% situtiaons, the hydrodynamic wake downstream of the profiler can
% catch up and distort the measurements.  Slow descent rates or
% decelarations are often caused by ship heave, especially when the
% instrument is being lowered by a winch (ie, not free falling).
% 
% The Hakai RBR descent rate working group found that density
% inversions typically occured during periods of slow descent rate and
% deceleration.  In particular, the data were suspect when the
% following critera were met:
%
%  The deceleration falls below -0.1 m/s^2 AND ...
%  the drop speed falls below 0.4 m/s.
%
% Finally, note that these values are derived for the downcast.
% Applying loopRBR to the upcast will produce strange results, however
% the upcast is not generally useful for scientific purposes.

minDescentRate = 0.4; % m/s
minDecelRate = -0.1;  % m/s^2

out = in;

% Check if Depth exists.  Calculate if not.
if ~isfield(in,'Depth'),
  out.Depth = -gsw_z_from_p(out.Pressure,out.Latitude);
  out.units(end+1) = {'m'};
end

% Check if Descent Rate exists.  Calculate if not.
if ~isfield(in,'DescentRate'),
    
    np = 3; % Jen's recommendation
    fltr = boxcar(np)/sum(boxcar(np));fltr = fltr(:);
    fdpth = filtfilt(fltr,1,out.Depth);
    
    out.DescentRate = diff(fdpth)./out.samplingPeriod; % m/s
    
    % put the descent rate on the original time stamp
    mtime = out.mtime(1:end-1) + diff(out.mtime)/2;
    out.DescentRate = interp1(mtime,out.DescentRate,out.mtime,...
                              'linear','extrap');

    out.units(end+1) = {'m/s'};
     
end

% Check if acceleration rate exists. Calculate if not
if ~isfield(in,'DecelRate'),
 
    out.DecelRate = diff(out.DescentRate)./out.samplingPeriod; % m/s^2
    mtime = out.mtime(1:end-1) + diff(out.mtime)/2;
    out.DecelRate = interp1(mtime,out.DecelRate,out.mtime,...
                            'linear','extrap');
    out.units(end+1) = {'m/s^2'};

end

%% flag data which do not meet the minimum velocity and acceleration criteria
kk = out.DescentRate <= minDescentRate & ...
     out.DecelRate   <= minDecelRate;

kk = kk | out.DescentRate < 0; % also toss extreme cases when CTD loops


%% apply the flag to the sensor data

% list of sensors to flag
vars = out.channels;


for j = 1:length(vars),

    switch replaceWith
        
      case 'NaN'
        out.(vars{j})(kk) = NaN;
        
      case 'interp'
        
        tvar = in.(vars{j});
        
        out.(vars{j}) = interp1(in.mtime(~kk),tvar(~kk),in.mtime);
    
    end
    
end



%% append the processing log

nlog = length(in.processingLog);

out.processingLog(nlog+1) = {['Scans for which the descent rate was ' ...
                              'lower than ' num2str(minDescentRate) ' m/s ' ...
                              'and the deceleration rate was lower ' ...
                              'than ' num2str(minDecelRate) ' m/s^2 were ' ...
                              'replaced with ' replaceWith '.']};


