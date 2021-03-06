function out = rmPatmRBR(in,patm)
%
% usage: out = rmPatmRBR(in,patm)
%
%
%   where
%     in        : structure of rbr data created by output from
%                 rbrExtractVals.m
%
%     patm      : Optional input argument specifying atmospheric 
%                 pressure.  Use 10.1325 dbar to specify the nominal 
%                 atmospheric sea level pressure.  If not supplied, 
%                 then rmPatmRBR estimates atmospheric pressure as 
%                 the median of all pressure measurements occuring 
%                 when conductivity is less than 1 mS/cm.  Note that 
%                 using the near-zero conductivity to find in-air 
%                 pressure will likely fail in fresh water.  In this
%                 case you can either specify your own atmoshperic
%                 pressure or reduce the conductivity threshold.
%
%  Mark Halverson, July 2016
    


out = in;


if nargin==1,

    % find all the in-air values, defined as scans when C<1 mS/cm.
    kk = in.Conductivity<1;

    % atmospheric pressure is median of all the in-air pressure values
    patm = nanmedian(in.Pressure(kk));

end


out.Pressure = out.Pressure - patm;


%% append processing log

nlog = length(in.processingLog);

out.processingLog(nlog+1) = {['Atmospheric pressure of ' num2str(patm,6) ...
                    ' dbar removed from total pressure']};
