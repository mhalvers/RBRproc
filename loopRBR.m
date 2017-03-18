function out = loopRBR(in,replaceWith,minDescentRate,minAccelRate)
%
%
% Filter channels based on the logger descent rate and (optionally)
% acceleration.
%
% usage: out = loopRBR(in,replaceWith,minDescentRate,minAccelRate)
%
%
%   where
%     in           : Structure of rbr data created by output from
%                    rbrExtractVals.m
%
%    replaceWith   : Switch specifying how to treat the flagged values:
%                  :     'interp'   - linear interpolation over flagged values
%                  :     'NaN'      - replace flagged values with NaN
%                  :     'remove'   - remove data
%                
%    minDescentRate: Threshold descent rate.  Data below this threshold
%                    are flagged and replaced with a NaN or an 
%                    interpolated value.
%
%    minAccelRate  : (Optional) Threshold acceleration.  Data below this 
%                    threshold are flagged and replaced with a NaN or an 
%                    interpolated value.
%
%
% loopRBR identifies scans for which the data is likely of poor
% quality because of slow descent rates and deceleration.  In such
% situations, the hydrodynamic wake downstream of the profiler can
% catch up and distort the measurements.  Slow descent rates or
% decelerations are often caused by ship heave, especially when the
% instrument is being lowered by a taut wire (i.e., not free falling).
% 
% The Hakai RBR descent rate working group found that density
% inversions typically occurred during periods of slow descent rate
% and deceleration.  In particular, the data were suspect when the
% following criteria were met:
%
%  The deceleration falls below -0.1 m/s^2 AND ...
%  the drop speed falls below 0.4 m/s.
%
% Finally, note that these values are derived for the downcast of
% lowered CTD data.  In cases where the upcast is desireable, such as
% when mounted on a Wirewalker or autonomous Lagrangian float, specify
% a negative descent rate.


%% input checking
if nargin<3,
  error(['loopRBR requires at least 3 arguments'])
end
if nargin==3,
  minAccelRate = [];
end


out = in;

% Check if Depth exists.  Calculate if not.
if ~isfield(in,'Depth'),
  out.Depth = -gsw_z_from_p(out.Pressure,out.Latitude);
  out.units(end+1) = {'m'};
end

%% Calculate descent rate
    
% first smooth the Depth time series
np = 5; 
fltr = boxcar(np)/sum(boxcar(np));fltr = fltr(:);
fdpth = filtfilt(fltr,1,out.Depth);

if isa(out.samplingPeriod,'duration'),
  dt = seconds(out.samplingPeriod);
else
  dt = out.samplingPeriod;
end


out.DescentRate = diff(fdpth)./dt; % m/s
    
% put the descent rate on the original time stamp
mtime = out.mtime(1:end-1) + diff(out.mtime)/2;
out.DescentRate = interp1(mtime,out.DescentRate,out.mtime,...
                          'linear','extrap');
out.units(end+1) = {'m/s'};
     

%% Calculate acceleration
if ~isempty(minAccelRate),
  out.AccelRate = diff(out.DescentRate)./dt; % m/s^2
  mtime = out.mtime(1:end-1) + diff(out.mtime)/2;
  out.AccelRate = interp1(mtime,out.AccelRate,out.mtime,...
                          'linear','extrap');
  out.units(end+1) = {'m/s^2'};
end

%% flag data which do not meet the minimum velocity and acceleration criteria

% velocity
kk = out.DescentRate <= minDescentRate;

% acceleration
if ~isempty(minAccelRate),
  kk = kk & out.AccelRate;
end
    


%% apply the action to the flagged data

% first develop a list of sensors
% vars = out.channels;



% get all fieldnames
vars = fieldnames(out);

% find the ones that are from sensors (or derived quantities)
jj = structfun(@(x) numel(x),out)==length(out.mtime);
vars = vars(jj);

% we don't want to flag and treat pressure, depth, or time unless the
% choice is to remove the data
if strcmp(replaceWith,'interp') | strcmp(replaceWith,'NaN'),
  keep = {'mtime' 'Pressure' 'Depth' 'DescentRate' 'AccelRate'};  
  vars = vars(~ismember(vars,keep));
end

for j = 1:length(vars),

    switch replaceWith
        
      case 'NaN'

        out.(vars{j})(kk) = NaN;
        
      case 'interp'
        
        tvar = out.(vars{j});
        
        out.(vars{j}) = interp1(out.mtime(~kk),tvar(~kk),out.mtime);
    
      case 'remove'
        
        tvar = out.(vars{j});
        out.(vars{j}) = tvar(~kk);
        
    end
    
end



%% append the processing log

if isfield(in,'processingLog');
  nlog = length(in.processingLog);
else
  nlog = 0;
end

if ~isempty(minAccelRate),
  out.processingLog(nlog+1) = {['Scans for which the descent rate was ' ...
                                'lower than ' num2str(minDescentRate) ' m/s ' ...
                                'and the deceleration rate was lower ' ...
                                'than ' num2str(minAccelRate) ' m/s^2 were ' ...
                                'replaced with ' replaceWith '.']};
else
  out.processingLog(nlog+1) = {['Scans for which the descent rate was ' ...
                                'lower than ' num2str(minDescentRate) ' m/s ' ...
                                'were replaced with ' replaceWith '.']};
end


