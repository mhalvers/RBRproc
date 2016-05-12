function out = despikeRBR(in,vars,algorithm,np,replaceWith)

% usage: 
% out = despikeRBR(in,vars,algorithm,np,replaceWith,val)
%
%  where:
%    in          : structure of rbr data (ie output from rbrExtractVals.m)   
%    vars        : cell array of strings describing which variables
%                  to filter
%    algorithm   : one of 'median' or 'mean'
%    np          : number of points in running mean/median
%    replaceWith : How to treat the flagged values:
%                :   one of 'filtered', 'interp', or 'NaN' 
%                :     'filtered' - use filtered (mean/median) version
%                :     'interp'   - linear interpolation over flagged values
%                :     'NaN'      - replace flagged values with NaN
%


if ischar(vars),
    vars = cellstr(vars);
end

out = in;


for j = 1:length(vars)

    tvar = in.(vars{j});

    switch algorithm
        
      case 'median'

        ftvar = medfilt1(tvar,np,'omitnan');
    
      case 'mean'
         
        fltr = boxcar(np)/sum(boxcar(np));fltr = fltr(:);
        ftvar = tvar;
        
        kk = isfinite(ftvar); % quick and dirty handling of NaNs (not great) 
        ftvar(kk) = filtfilt(fltr,1,tvar(kk)); 

    end

    % pick out the offenders
    
    res = tvar - ftvar;
    
    thresh = 4*nanstd(res);
    jj = abs(res) >= thresh;
    

    switch replaceWith
  
      case 'filtered'

        out.(vars{j}) = ftvar;
        
      case 'interp'

        out.(vars{j}) = interp1(in.mtime(~jj),tvar(~jj),in.mtime);
    
      case 'NaN'

        tvar(jj) = NaN;
        out.(vars{j}) = tvar;
            
    end

end



if numel(vars)>1,
    vars = strjoin(vars,', ');
end


nlog = length(out.processingLog);
out.processingLog(nlog+1) = {['De-spiking applied to ' char(vars) ...
                    ' with ' num2str(np) ' point ' algorithm  ...
                    ' algorithm.  Bad values treated with ' ...
                    replaceWith '.']};
