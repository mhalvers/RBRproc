function casts = rbrExtractVals(profile);

% Takes the output structure from RSKreaddata(rskfile) and converts it
% into a useful structure.
%
% Converts it into a ncast x 1 structure with easily accessible data.
%
% File is parsed into casts by finding large gaps in the time record.
% This is rather crude and it will most certainly fail under some
% circumstances.  Use trimRBR to select downcasts and upcasts.
%
% Note that using the '.profiles' for finding the up and downcasts
% will remove the soak period, which can be useful for some purposes.
%
% In the future rbrExtractVals might be altered to identify the
% upcasts and downcasts, and provide indices to extract them.


% for testing
% profile = rsk;
% clear rsk casts


%% create a temporary structure with relavant info in a simpler format

rbr.fileName = profile.deployments.name;
rbr.samplingPeriod = profile.schedules.samplingPeriod/1000; % seconds
rbr.mtime = profile.data.tstamp;
rbr.channels = {profile.channels.longName};
rbr.units = {profile.channels.units};
rbr.serialID = num2str(profile.instruments.serialID);
rbr.model = profile.instruments.model;
if isfield(profile,'profiles'),
  rbr.profiles = profile.profiles;
end

vars = rbr.channels;

for k=1:length(vars),
    
    lbl = vars{k};
    
    ind = ~cellfun('isempty',strfind(vars,lbl));
    
    % replace spaces with underscores
    lbl = strrep(lbl,' ','_');
    
    % replace empty and nonprintable characters in 'Dissolved O‚€'
    if strcmp(lbl(1:3),'Dis'),
        lbl(lbl>=128) = ''; %ascii values
        lbl(end+1) = '2';
    end
    
    rbr.(lbl) = profile.data.values(:,ind);
    
    vars(k) = {lbl};
    rbr.channels(k) = {lbl};
end


%% get the start and end times of each profile
% use trimRBR.m to separate the upcasts and downcasts

% for testing
% plot(rbr.mtime,rbr.Pressure,'o','markersize',4)
% zoom on;grid on;fillMarkers;
% zoomAdaptiveDateTicks('on');
% fsize(15);

dt = 3; % time gap in minutes

ind = find(diff(rbr.mtime)>dt/60/24);
ind = [1; ind+1];
tstart = rbr.mtime(ind);

ind = find(diff(rbr.mtime)>dt/60/24);
ind = [ind; length(rbr.mtime)];
tend = rbr.mtime(ind);
    



%% transform into multidimensional structure, ncast x 1

for k = 1:length(tstart),
    
    kk = rbr.mtime>=tstart(k) & rbr.mtime<=tend(k);
    
    casts(k).fileName = rbr.fileName;
    casts(k).channels = rbr.channels;
    casts(k).units = rbr.units;
    casts(k).serialID = rbr.serialID;
    casts(k).model = rbr.model;
    casts(k).tzone = '?';
    casts(k).samplingPeriod = rbr.samplingPeriod;
    
    if isfield(rbr,'profiles'),
        try % b/c RBR and I sometimes disagree on the # of profiles
            casts(k).profiles.downcast.tstart = rbr.profiles.downcast.tstart(k);
            casts(k).profiles.downcast.tend = rbr.profiles.downcast.tend(k);
            casts(k).profiles.upcast.tstart = rbr.profiles.upcast.tstart(k);
            casts(k).profiles.upcast.tend = rbr.profiles.upcast.tend(k);
        catch
            casts(k).profiles.downcast.tstart = [];
            casts(k).profiles.downcast.tend = [];
            casts(k).profiles.upcast.tstart = [];
            casts(k).profiles.upcast.tend = [];
        end
    end
    
    casts(k).mtime = rbr.mtime(kk);

    for j = 1:length(vars),
      casts(k).(vars{j}) = rbr.(vars{j})(kk);    
    end
    
    casts(k).processingLog = {[rbr.fileName ' converted into RBRproc ' ...
                    'structure.  Parsed file into casts.']};


end

%% print out some useful information

disp(['Found ' num2str(k) ' casts with start times:'])
disp(datestr(arrayfun(@(x) min(x.mtime),casts)))


