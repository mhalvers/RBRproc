function out = alignRBR(in,nscan)

% Align the data by shifting the lagging the conductivity a few scans.
% Pressure and temperature are (physically) close together, and thus
% matched closely in time.  Conductivity measurment made in advance
% of pressure and temperature.
%
% Hard-wired to delay C relative to T and P.  Default is 2 scans

if nargin==1,
  nscan = 2;
end


out = in;

out.Conductivity = cat(1,NaN(nscan,1),in.Conductivity(1:end-nscan));


nlog = length(out.processingLog);
out.processingLog(nlog+1) = {['Conductivity advanced ' num2str(nscan) ' scans relative to Temperature']};

