function out = binRBR(in,by,binWidth)

% bin average RBR profiles
%
%  out = binRBR(in,by,binWidth);
%
%   where 
%     in        : structure of RBR profiler data (i.e., created 
%                 by output from rbrExtractVals.m)
%     by        : is a string specifying how to bin the  data 
%                 ('depth' or 'pressure')
%     binWidth  : is the bin width
%
%   note: if by = 'depth', and depth hasn't yet been calculated, then
%         depth is calculated from pressure and latitude using the GSW
%         function gsw_z_from_p

 
%% for testing
% in = profile; 
% % by = 'depth';
% by = 'pressure';
% binWidth = 1;
  

%% develop a list of sensors to bin
vars = fieldnames(in);
ind = [];
for k=1:length(vars),
    if isnumeric(in.(vars{k})) & numel(in.(vars{k}))>1,
        ind = [ind; k];
    end
end
vars = vars(ind);

% of course we don't want to bin pressure or depth
vars = vars(~strcmp(vars,{'Pressure'}));
vars = vars(~strcmp(vars,{'Depth'}));



out = in;

switch by
  case 'pressure'
    binCenter = [binWidth:binWidth:ceil(max(in.Pressure))]';
    out.Pressure = binCenter;
    unit = 'dbar'; % for processing log text
  case 'depth'
    in.Depth = -gsw_z_from_p(in.Pressure,52);
    binCenter = [binWidth:binWidth:ceil(max(in.Depth))]';
    out.Depth = binCenter;
    out.Pressure = gsw_p_from_z(-out.Depth,52);
    unit = 'm'; % for processing log text
end
out.units(end+1) = {'m'};



%  initialize the binned output fields    
for k=1:length(vars),
  out.(vars{k}) = NaN(length(binCenter),1);
end


for k=1:length(binCenter),

  switch by
    case 'pressure'
      kk = in.Pressure>=binCenter(k)-binWidth/2 & ...
           in.Pressure< binCenter(k)+binWidth/2;
    case 'depth'
      kk = in.Depth>=binCenter(k)-binWidth/2 & ...
           in.Depth< binCenter(k)+binWidth/2;
  end
  
  if any(kk),
     for j=1:length(vars),
       out.(vars{j})(k) = nanmean(in.(vars{j})(kk));         
     end
  end

end


%% append processing log

if isfield(in,'processingLog');
  nlog = length(in.processingLog);
else
  nlog = 0;
end

out.processingLog(nlog+1) = {['Data binned by ' by ' to ' num2str(binWidth) ...
                    ' ' unit ' intervals']};
