# RBRproc

A collection of Matlab routines to process RBR profiler data (eg RBR
concerto).  The approach here largely resembles the processing chain
used by Seabird profilers, except that the parameters are tuned for
RBR profilers.

At the moment it users are required to use RSKtools to read raw 'rsk'
sqlite files into Matlab.  The output structure is then converted into
a multidimensional structure.  This structure is then used as input to
the various routines.  It has a crude processing log.



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
rbr = rbrExtractVals(rsk); 

% extract the 4th profile for this example
profile = rbr(4);  

% low pass filter (filtfilt) T/C with running 3 pt triangular window
profile = filterRBR(profile,{'Temperature','Conductivity'},3);

%  lag conductivity by 2 scans to reduce salinity spiking
profile = alignRBR(profile,'Conductivity',-2);

% now re-calculate practical salinity
profile.Salinity = gsw_SP_from_C(profile.Conductivity,....
                                 profile.Temperature,...
                                 profile.Pressure);

% interactive function to choose start and end points of profile
profile = trimRBR(profile);

% despike the fluorometer and turbidity profiles.  Use an 11 point
% median filter to find the spikes, and replace them with NaN
profile = despikeRBR(profile,{'Fluorometer','Turbidity'},'median',11,'NaN');

%% bin average all variables by pressure into 1 dbar bins
profile = binRBR(profile,'pressure',1);

```

## Laundry list
