function [out,ind] = trimRBR(in,ind),

% trimRBR discards scans from an RBR profile.  
%
%  usage: out = trimRBR(in,ind);
%
%   where:
%      in          : structure of rbr data (ie output from 
%                  : rbrExtractVals.m)
%      ind         : If known, optional vector of indices to retain.  
%
%      If ind is not specified, trimRBR launches a (crude) interactive
%      window prompting the user to select the cast limits by hand.
%      The indices selected with the gui are then provided as an
%      output.
%

out = in;

if nargin==1,
    
    for k = length(in),
  
        if k==1;fh = figure;end
        if k>1;figure(fh);end
        clf
  
        plot(in.Pressure,'ko-')    
        grid on;
  
        disp('Press any key after zooming to choose profile start')
        zoom on;
        pause
        disp('Choose start point')
        [xs(k),~] = ginput(1);
        clf
  
        plot(in.Pressure,'ko-')    
        grid on;
        zoom on
        disp('Press any key after zooming to choose profile end')
        pause
        disp('Choose end point')
        [xe(k),~] = ginput(1);
        
        if k==length(in);close(fh);end
    end

elseif nargin==2,

    xs = ind(1);
    xe = ind(end);
    
end



for k = 1:length(in)
    ind = ceil(xs(k)):floor(xe(k));

    vars = fieldnames(in(k));
    %cls = structfun(@isnumeric,in,'uniformoutput',false);

    for j = 1:length(vars)
        if isnumeric(in.(vars{j})) & numel(in.(vars{j}))>1,
            out.(vars{j}) = in.(vars{j})(ind);
        end
    end

    nlog = length(out(k).processingLog);
    out(k).processingLog(nlog+1) = {['Profile trimmed']};

end




