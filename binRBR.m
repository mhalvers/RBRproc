function out = binRBR(in,by,binWidth)

% bin average RBR profiles
%
%  out = binRBR(in,by,binWidth);
%
%   where 'in' is the RBR structure
%         'by' is a string specifying how toh
%              bin the data ('depth' or 'pressure')
%         'binWidth' is the bin width
%
%   note: if by = 'depth' then depth is calculated
%         from pressure and latitude using the GSW 
%         function gsw_z_from_p


%% for testing
% in = profile; 
% by = 'depth';
% % by = 'pressure';
% binWidth = 1;

out = in;


unit = 'dbar'; % for processing log text

if strcmp(by,'depth'),
  in.Depth = -gsw_z_from_p(in.Pressure,52);
  in.units(end+1) = {'m'};
  % in = orderfields(in,'processingLog',length(fieldnames(in)))
  unit = 'm'; % for processing log text
end


vars = fieldnames(in);
ind = [];
for k=1:length(vars),
    if isnumeric(in.(vars{k})),
        ind = [ind; k];
    end
end
vars = vars(ind);


switch by
  case 'pressure'
    binCenter = [1:binWidth:ceil(max(in.Pressure))]';
    out.Pressure = binCenter;
    vars = vars(~strcmp(vars,'Pressure'));
  case 'depth'
    binCenter = [1:binWidth:ceil(max(in.Depth))]';
    out.Depth = binCenter;
    vars = vars(~strcmp(vars,'Depth'));
    out.Pressure = gsw_p_from_z(-out.Depth,52);
end


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


nlog = length(out.processingLog);
out.processingLog(nlog+1) = {['Data binned by ' by ' to ' num2str(binWidth) ' ' unit]};