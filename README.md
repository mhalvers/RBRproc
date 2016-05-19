# RBRproc

RBRproc is a collection of Matlab routines designed to process RBR
profiler data (eg, RBR concerto).  The approach here largely resembles
the processing chain used by Seabird profilers, except that the
parameters are tuned for RBR profilers.

At the moment the toolbox is designed to use RBR's RSKtools Matlab
toolbox to read raw 'rsk' sqlite files.  The output structure from
RSKtools is then converted into a more convenient multidimensional
structure.  This structure is then used as input to the various
RBRproc processing routines.  For RBR loggers which output hexadecimal
files, one could also read any one of the Ruskin outputs (mat, txt,
Excel, etc) into Matlab and create a structure resembling the output
of rbrExtractVals.m.


## Requirements

### RSKtools

[RBR Global link](http://www.rbr-global.com/support/matlab-tools)

[Github page](https://github.com/RBRglobal/RSKtools)


### Gibbs SeaWater Matlab tool box
[TEOS-10 link](http://www.teos-10.org/software.htm)

## Example usage

```matlab
% read logger data into Matlab using RSKtools
rsk = RSKopen(rskfile);
rsk = RSKreaddata(rsk);
```


```matlab
% puts things in a friendly 1 x Ncast structure
% note that rbrExtractVals converts total pressure to
% sea pressure by assuming Patm = 10.1325 dbar
profiles = rbrExtractVals(rsk); 

% extract the 4th profile for this example
profile = profiles(4);

% low pass filter (filtfilt) T/C with running 3 pt triangular window
profile = filterRBR(profile,{'Temperature','Conductivity'},3);

% lag conductivity by 0.33 seconds (2 scans at 6 Hz) to reduce salinity spiking
profile = alignRBR(profile,'Conductivity',-2/6);

% now calculate practical salinity
profile = rmfield(profile,'Salinity'); % remove RBR's calculation

profile.PracticalSalinity = gsw_SP_from_C(profile.Conductivity,....
                                          profile.Temperature,...
                                          profile.Pressure);

% interactive function to choose start and end points of profile
profile = trimRBR(profile);

% despike the fluorometer and turbidity profiles.  Use an 11 point
% median filter to find the spikes, and replace them with NaN
profile = despikeRBR(profile,{'Chlorophyll','Turbidity'},'median',11,'NaN');

%% bin average all variables by pressure into 1 dbar bins
profile = binRBR(profile,'pressure',1);

```

## Laundry list

1. Modify `despikeRBR.m` to operate on blocks of data instead of full profile.
2. Remove the atmospheric pressure correction from `rbrExtractVals.m`
   and place elsewhere?
3. Improve the profile detection in `rbrExtractVals.m`.
4. Add up/down cast detection to `trimRBR.m`.
