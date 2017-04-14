# RBRproc

RBRproc is a collection of Matlab routines designed to process RBR
profiler data (e.g., RBR Concerto).  The approach here largely
resembles the processing chain used by Seabird profilers.

At the moment the toolbox is designed to use RBR's RSKtools Matlab
toolbox to read raw 'rsk' sqlite files.  The output structure from
RSKtools is then converted into a more convenient structure.  This
structure is then used as input to the various RBRproc processing
routines.

For the older RBR loggers that output hexadecimal files, first use
Ruskin to export the file into any one of the Ruskin outputs (mat,
txt, Excel, etc.).  Then read that file into Matlab.  Following this,
insert the data into the blank structure created by the function
`blankRBRstruct.m`.  Matlab functions to read RBR hex or txt files do
not exist as far as I know (volunteers?), but reading Excel files and
mat files in Matlab is trivial.


## Requirements

### RSKtools

Official releases:

[RBR Global link](http://www.rbr-global.com/support/matlab-tools)

Bleeding edge development version:

[Bitbucket](https://bitbucket.org/rbr/rsktools)


### Gibbs SeaWater Matlab tool box
[TEOS-10 link](http://www.teos-10.org/software.htm)

## Example usage

In this example we will read an rsk file and extract the downcasts
using functions in RSKtools, and then perform some basic processing
with RBRproc.

```matlab
% read logger data into Matlab using RSKtools
rsk = RSKopen('/full/path/to/rskfile');

% parse the file into profiles, keeping only the down casts
profiles = RSKreadprofiles(rsk,[],'down');

% recast things into a 1 x Ncast structure with easy-to-access fields.
% the field names come from rsk.channels.longName
profiles = flattenRSK(profiles);

% plot a time series of pressure to see the profiles
plot(cat(1,profiles.mtime),cat(1,profiles.Pressure)-10.1325,'.-')
title(profiles(1).fileName,'interpreter','none')

% find the maximum pressure of each profile
arrayfun(@(x) max(x.Pressure),profiles)

% extract the 4th profile for this example
profile = profiles(4);

% add coordinates to structure
profile.Latitude = 52;
profile.Longitude = -129;

% subtract a user-chosen atmospheric pressure from total pressure
patm = 9.9; % say a mid-latitude low pressure system was passing by 
profile = rmPatmRBR(profile,patm);

% despike the fluorometer and turbidity profiles.  Use an 11 point
% median filter to find the spikes, and replace them with NaN
profile = despikeRBR(profile,{'Chlorophyll','Turbidity'},'median',11,'NaN');

% low pass filter (filtfilt) T/C with running 3 pt triangular window
profile = filterRBR(profile,{'Temperature','Conductivity'},3);

% lag conductivity by 0.33 seconds (2 scans at 6 Hz) to reduce
% salinity spiking 
profile = alignRBR(profile,'Conductivity',-2/6);

% Identify scans when the descent rate was below 50 cm/s data, and
% replace with `NaN`.
profile = loopRBR(profile,'NaN',0.5);

% now calculate practical salinity
if isfield(profile,'Salinity'),
  profile = rmfield(profile,'Salinity'); % remove RBR's calculation
end

profile.PracticalSalinity = gsw_SP_from_C(profile.Conductivity,....
                                          profile.Temperature,...
                                          profile.Pressure);

% interactive function to choose start and end points of profile
% (this could use some work from a GUI expert)
profile = trimRBR(profile);

%% bin average all variables by pressure into 1 dbar bins
profile = binRBR(profile,'pressure',1);

```

## Laundry list

1. Implement better input handling.

2. Modify `despikeRBR.m` to operate on blocks of data instead of full
profile.

3. Make trimRBR not suck.

4. Depth vector has the incorrect length when it is calculated by
loopRBR, but then binned by pressure.
