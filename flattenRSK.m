function out = flattenRSK(in);

% Takes the output structure from the RSKtools functions RSKreaddata
% or RSKreadprofiles and converts it into a useful structure that has
% easy to read fields (e.g., rbr.Conductivity).  The output structure
% is required for further processing by functions in RBRproc.
%
% If the input file was created by RSKreadprofiles, and the file
% contains multiple profiles, flattenRSK outputs a structure with
% dimensions 1 x Ncast.
%
%  usage: out = filterRBR(in);
%
%   where:
%      in          : structure of rbr data (i.e., output from 
%                  : RSKreadata or RSKreadprofiles)
%
%  Mark Halverson  06/Apr/2017


%% does the structure come from RSKreaddata or RSKreadprofiles?
isDown = isfield(in.profiles.downcast,'data');
isUp = isfield(in.profiles.upcast,'data');

isProfile = isDown | isUp;

if isDown,castdir='downcast';end
if isUp,castdir='upcast';end


%% construct a list of channels
% are there multiple Temperature strings?  append a number

vars = {in.channels.longName};
ii = strcmp(vars,'Temperature');
no = strread(num2str(1:sum(ii)),'%s')';
if sum(ii)>1,
  vars(ii) = strcat(vars(ii),no);    
end

%% fix up variable names so are valid structure field names
for k=1:length(vars),

  lbl = vars{k};

  % replace spaces with underscores
  lbl = strrep(lbl,' ','_');

  % replace empty and nonprintable characters in 'Dissolved O<82><80>'
  if strcmp(lbl(1:3),'Dis'),
    lbl(lbl>=128) = ''; %ascii values
    lbl(end+1) = '2';
  end

  vars(k) = {lbl};

end



%% determine number of profiles
castno = 1;
if isProfile,
  castno = length(in.profiles.(castdir).data);
end

for m=1:castno,

  out(m).samplingPeriod = seconds(in.schedules.samplingPeriod/1000);
  out(m).fileName = in.deployments.name;
  out(m).serialID = num2str(in.instruments.serialID);
  out(m).model = in.instruments.model;


  if isProfile,
    out(m).mtime = in.profiles.(castdir).data(m).tstamp;
  else
    out(m).mtime = in.data.tstamp; 
  end

  
  for k=1:length(vars),
  
    if isProfile,
      out(m).(vars{k}) = in.profiles.(castdir).data(m).values(:,k);
    else
      out(m).(vars{k}) = in.data.values(:,k);
    end 
    
  end

  units = {in.channels.units};
  for k=1:length(units),
    out(m).units.(vars{k}) = units(k);
  end


  out(m).processingLog = {'sqlite table structure simplified with flattenRSK.m'};


end
