# RBRproc

A collection of matlab routines to process RBR profiler data (eg RBR
concerto).  The approach here largely resembles the processing chain
used by Seabird profilers, except that the parameters are tuned for 
RBR profilers.

It makes use of 



## requires 
[RSKtools](http://www.rbr-global.com/support/matlab-tools)
[(Github page here)](https://github.com/RBRglobal/RSKtools)


[Gibbs SeaWater Matlab tool box](http://www.teos-10.org/software.htm)

## Example usage:

```matlab
rsk = RSKopen(rskfile); % from RSKtools
rsk = RSKreaddata(rsk);
```


```matlab
rbr = rbrExtractVals(rsk); % puts things in a friendly structure

profile = rbr(4);  % extract the 4th profile for an example

% low pass filter T/C
profile = filterRBR(profile);

%  lag conductivity to reduce salinity spiking
profile = alignRBR(profile,2);

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
