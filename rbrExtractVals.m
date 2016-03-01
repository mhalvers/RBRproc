function casts = rbrExtractVals(profile,upDownOrBoth);

% Takes the output structure from RSKreaddata(rskfile)
% and converts it into a useful structure
%
% Converts it into a ncast x 1 structure with easily
% accessible data.
%
% Uses time record to find large gaps to delineate 
% individual profiles.  This is rather crude and it
% will most certainly fail.  Also, it selects both
% the up and down casts.  Use trimRBR to parse casts
% further.
%
% Currently also subracts 10.1325 dbar from the total
% pressure to form sea pressure.  This should probably
% be moved to another function, or at least be an
% input variable.

% upDownOrBoth = 'both'; % only one that works now
% % upDownOrBoth = 'up';
% % upDownOrBoth = 'down';

if nargin==1,
  upDownOrBoth = 'both';
end



rbr.mtime = profile.data.tstamp;
rbr.units = profile.data.units;
rbr.serialID = num2str(profile.instruments.serialID);
rbr.model = profile.instruments.model;
if isfield(profile,'profiles'),
  rbr.profiles = profile.profiles;
end

vars = profile.data.longName;

for k=1:length(vars),
    
    lbl = vars{k};
    
    ind = ~cellfun('isempty',strfind(vars,lbl));
    
    % replace empty and nonprintable characters in 'Dissolved O‚€'
    if strcmp(lbl(1:3),'Dis'),
        lbl(lbl==32 | lbl>=128) = ''; %ascii values
        lbl(end+1) = '2';
        vars(k) = {lbl};
    end
    
    rbr.(lbl) = profile.data.values(:,ind);

end
rbr.Pressure = rbr.Pressure - 10.1325;



switch (lower(upDownOrBoth(1:2)))
  case 'bo'
    strt = 'downcast';
    endt = 'upcast';
  case 'up'
    strt = 'upcast';
    endt = 'upcast';
  case 'do'
    strt = 'downcast';
    endt = 'downcast';
end

if isfield(rbr,'profiles'),
    
    tstart =  rbr.profiles.(strt).tstart;
    tend   =  rbr.profiles.(endt).tend;
    
else

    ind = find(diff(rbr.mtime)>10/60/24);
    ind = [1; ind+1];
    tstart = rbr.mtime(ind);
    ind = find(diff(rbr.mtime)>10/60/24);
    ind = [ind; length(rbr.mtime)];
    tend = rbr.mtime(ind);
    
end



%% transform into multidimensional structure, ncast x 1

% t_end works, but not t_start, so only use t_end
for k = 1:length(tend),
    
    if k==1,
        kk = rbr.mtime<tend(k);
    elseif k>1,
        kk = rbr.mtime>tend(k-1) & rbr.mtime<tend(k);
    end
    
    casts(k).units = rbr.units;
    casts(k).serialID = rbr.serialID;
    casts(k).model = rbr.model;
    casts(k).tzone = '?';
    
    if isfield(rbr,'profiles'),
        casts(k).profiles.downcast.tstart = rbr.profiles.downcast.tstart(k);
        casts(k).profiles.downcast.tend = rbr.profiles.downcast.tend(k);
        casts(k).profiles.upcast.tstart = rbr.profiles.upcast.tstart(k);
        casts(k).profiles.upcast.tend = rbr.profiles.upcast.tend(k);
    end
    
    casts(k).mtime = rbr.mtime(kk);
    
    for j = 1:length(vars),
      casts(k).(vars{j}) = rbr.(vars{j})(kk);    
    end
    
end


