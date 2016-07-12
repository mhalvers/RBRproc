# RBRproc

RBRproc is a collection of Matlab routines designed to process RBR
profiler data (eg, RBR concerto).  The approach here largely resembles
the processing chain used by Seabird profilers, except that the
parameters are tuned for RBR profilers.

At the moment the toolbox is designed to use RBR's RSKtools Matlab
toolbox to read raw 'rsk' sqlite files.  The output structure from
RSKtools is then converted into a more convenient multidimensional
structure.  This structure is then used as input to the various
RBRproc processing routines.

For RBR loggers which output hexadecimal files, one could also read
any one of the Ruskin outputs (mat, txt, Excel, etc) into Matlab.
Following this, insert the data into the blank structure created by
the function `blankRBRstruct.m`.  Matlab functions to read RBR hex or
txt files do not exist as far as I know (volunteers?), but reading
Excel files and mat files in Matlab is trivial.


## Requirements

### RSKtools

Official releases:

[RBR Global link](http://www.rbr-global.com/support/matlab-tools)

Bleeding edge development version:

[Bitbucket](https://bitbucket.org/rbr/rsktools)


### Gibbs SeaWater Matlab tool box
[TEOS-10 link](http://www.teos-10.org/software.htm)

## Example usage

```matlab
% read logger data into Matlab using RSKtools
rsk = RSKopen(rskfile);
rsk = RSKreaddata(rsk);

% recast things into a friendly 1 x Ncast structure. casts are determined
% by finding large gaps in the time stamps
profiles = rbrExtractVals(rsk); 

% plot a time series of pressure to see the profiles
plot(cat(1,profiles.mtime),cat(1,profiles.Pressure)-10.1325,'.-')
title(profiles(1).fileName,'interpreter','none')

% find the maximum pressure of each profile
arrayfun(@(x) max(x.Pressure),profiles)

% extract the 4th profile for this example
profile = profiles(4);

% subtract atmospheric pressure from total pressure
patm = 9.5;
profile = rmPatmRBR(profile,patm);

% despike the fluorometer and turbidity profiles.  Use an 11 point
% median filter to find the spikes, and replace them with NaN
profile = despikeRBR(profile,{'Chlorophyll','Turbidity'},'median',11,'NaN');

% low pass filter (filtfilt) T/C with running 3 pt triangular window
profile = filterRBR(profile,{'Temperature','Conductivity'},3);

% lag conductivity by 0.33 seconds (2 scans at 6 Hz) to reduce salinity spiking
profile = alignRBR(profile,'Conductivity',-2/6);

% Identify scans when the descent rate and deceleration were such that
% hydrodynamic wake may have contaminated the data, and replace with `NaN`.
profile = loopRBR(profiles,'NaN');

% now calculate practical salinity
profile = rmfield(profile,'Salinity'); % remove RBR's calculation

profile.PracticalSalinity = gsw_SP_from_C(profile.Conductivity,....
                                          profile.Temperature,...
                                          profile.Pressure);

% interactive function to choose start and end points of profile
profile = trimRBR(profile);

%% bin average all variables by pressure into 1 dbar bins
profile = binRBR(profile,'pressure',1);

```

## Laundry list

1. Implement better input handling.

2. Improve the cast detection in `rbrExtractVals.m`.

3. Decide on where to implement upcast and downcast delineation.
Possibilities include `trimRBR.m`, `rbrExtractVals.m`, or perhaps a
new function.  Use the 'profiles' field, if it exists, to determine
the upcast and downcast.

4. Modify `despikeRBR.m` to operate on blocks of data instead of full
profile.

