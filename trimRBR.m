function out = trimRBR(in,ind),

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

    fnames = fieldnames(in(k));
    %cls = structfun(@isnumeric,in,'uniformoutput',false);

    for j = 1:length(fnames)
        if isnumeric(in.(fnames{j})),
            out.(fnames{j}) = in.(fnames{j})(ind);
        end
    end

    nlog = length(out(k).processingLog);
    out(k).processingLog(nlog+1) = {['Profiles trimmed']};

end




