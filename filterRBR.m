function [out] = filterRBR(in,fields)

% hardwired to use 3 point triangle window FIR
% on conductivity and temperature
%
% In the future, specify fields, or use IIR filter.


out = in;


% filter conductivity to match temperature response
np = 3;  
fltr = triang(np)/sum(triang(np));fltr = fltr(:);

out.Conductivity = filtfilt(fltr,1,in.Conductivity);

% filter temperature to ensure a match
out.Temperature =  filtfilt(fltr,1,in.Temperature);


%% filter pressure
% np = 5; % for pressure
% fltr = triang(np)/sum(triang(np));fltr = fltr(:);
% out.Pressure = filtfilt(fltr,1,in.Pressure);


% IIR butterworth
% [b,a] = butter(1,.5); % 1st order, 3 Hz cutoff (Wn = 3/6*2pi)
% freqz(b,a)
% fcon2 = filtfilt(b,a,con);


out.processingLog = {['Temperature and conductivty low pass filtered with '...
                     num2str(np) ' point triangular window']};


