function out = despikeRBR(in,vars,algorithm,np,replacewith)

% usage: 
% out = despikeRBR(in,vars,algorithm,np,replacewith,val)
%
%  where:
%    in          : structure of rbr data (ie output from rbrExtractVals.m)   
%    vars        : cell array of variables to filter. 'all' for all sensors
%    algorithm   : one of 'median' or 'mean'
%    np          : number of points in running mean/median
%    replacewith : How to treat the flagged values:
%                :   one of 'filtered', 'interp', or 'NaN' 
%                :     'filtered' - use filtered (mean/median) version
%                :     'interp'   - linear interpolation over flagged values
%                :     'NaN'      - replace flagged values with NaN
%

ind = [];
if strcmp(vars,'all'),

    fnames = fieldnames(in);
    
    for k=1:length(fnames),
      if isnumeric(in.(fnames{k})),
        ind = [ind; k];
      end
    end

    fnames = fnames(ind);
 
    ind = ~strcmp('mtime',fnames);
    fnames = fnames(ind);

elseif ischar(vars),

    fnames = {vars};

else

    fnames = vars;
    
end



out = in;


for j = 1:length(fnames)

    tvar = in.(fnames{j});

    switch algorithm
        
      case 'median'

        ftvar = medfilt1(tvar,np,'omitnan');
    
      case 'mean'
         
        fltr = boxcar(np)/sum(boxcar(np));fltr = fltr(:);
        kk = isfinite(tvar);
        ftvar = tvar;
        ftvar(kk) = filtfilt(fltr,1,tvar(kk)); 

    end

    % pick out the offenders
    
    res = tvar - ftvar;
    
    thresh = 3*nanstd(res);
    jj = res >= thresh;
    

    switch replacewith
  
      case 'filtered'
        out.(fnames{j}) = ftvar;
        
      case 'interp'
        
        tvar = interp1(in.mtime(~jj),tvar(~jj),in.mtime);
        out.(fnames{j}) = tvar;
    
      case 'NaN'
        tvar(jj) = NaN;
        out.(fnames{j}) = tvar;
            
    end

end



nlog = length(out.processingLog);
out.processingLog(nlog+1) = {['De-spiking applied to with ' num2str(np) [' ' ...
                    'point '] algorithm ' algorithm.  Bad values ' ...
                    'treated with ' replacewith '.']};