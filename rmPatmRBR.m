function out = rmPatmRBR(in,patm)
%
% usage: out = rmPatmRBR(in,patm)
%
%
%   where
%     in        : structure of rbr data created by output from
%                 rbrExtractVals.m
%
%     patm      : Optional input argument specifying atmosperhic 
%                 pressureof pressure value.  Use 10.1325 dbar 
%                 to specify the nominal atmospheric sea level
%                 pressure.  If not supplied, then rmPatmRBR
%                 estimates atmospheric pressure as the median of all
%                 pressure measurements occuring when conductivity is
%                 less than 1 mS/cm.  Note that using the near-zero 
%                 conductivity to find in-air pressure will likely 
%                 fail in fresh water.  But most lakes are not at sea 
%                 level, so you can either specify your own atmoshperic
%                 pressure anyway or reduce the conductivity threshold.
%
%  Mark Halverson, July 2016
    


out = in;


if nargin==1,

    % find all the in-air values, defined as scans when C<1 mS/cm.
    kk = profiles(k).Conductivity<1;

    % atmospheric pressure is median of all the in-air pressure recordings
    patm = nanmedian(profiles.Pressure(kk));

end


out.Pressure = out.Pressure - patm;


%% append processing log

nlog = length(in.processingLog);

out.processingLog(nlog+1) = {['Atmospheric pressure of ' num2str(patm,6) ...
                    ' dbar removed from total pressure']};
