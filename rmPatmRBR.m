function out = rmPatmRBR(in,patm)

if nargin == 1, 
    patm = 10.1325;
end


out = in;

out.Pressure = out.Pressure - patm;


%% append processing log

nlog = length(in.processingLog);

out.processingLog(nlog+1) = {['Atmospheric pressure of ' num2str(patm) ...
                    ' dbar removed from total pressure']};
