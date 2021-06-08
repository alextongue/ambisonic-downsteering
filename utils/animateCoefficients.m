function lp = animateCoefficients(s, signalIdx, plotOrders, downsamp, plotShape)

    assert(numel(s.signal)>=signalIdx, 'invalid signal index')
    assert(size(s.signal{signalIdx},1)>0, 'empty signal')

    res = s.grid.res;
    fs = s.fs;
    maxOrd = (numel(s.harmonics)-1);
    sigLen = size(s.signal{signalIdx},1);
    
    if isempty(plotOrders)
        plotOrders = 0:maxOrd;
    end
    if isempty(downsamp)
        downsamp = fs/10;
    end
    
    assert(all(plotOrders <= maxOrd) & all(plotOrders>=0), ...
        sprintf('Check order query (valid orders 0:%d)!',maxOrd));
    nCols = ceil(numel(plotOrders)/2);
    axhandles = [];
    
    if any(contains(plotShape,{'sph','proj'},'IgnoreCase', true))
%         viewDim = 3;
    elseif contains(plotShape,'rec','IgnoreCase', true)
%         viewDim = 2;
    else
        error('Only {"sph","rec","proj"} plotshapes supported!');
    end

   
    for tt = 1:downsamp:sigLen
        totalCplxSum = zeros(s.grid.res,s.grid.res);
        harmonicMtx = zeros(numel(s.harmonics)^2,res,res);
        
        % Concatenate harmonics
        channelIdx = 0;
        for mm_idx = 1:numel(s.harmonics)
            harmIdxs = channelIdx + (1:(mm_idx*2-1));
            harmonicMtx(harmIdxs,:,:) = s.harmonics(mm_idx).total;
            channelIdx = channelIdx + 2*mm_idx-1;
        end
        
        
        % Multiply concatenated signals and harmonics
        totalCplxSum = squeeze(sum(...
            harmonicMtx .* repmat(s.signal{signalIdx}(tt,:)', 1, res, res),...
            1));
        
        
        % sum together harmonics for each order
        %{
        for ii = 1:numel(plotOrders)
            mm_idx = plotOrders(ii)+1;
            sumMag = zeros(res, res);
            sumCplx = ...
                squeeze(sum( s.harmonics(mm_idx).total ...
                .* repmat(s.harmonics(mm_idx).coeffsig(tt,:)', 1, res, res),...
                1 ));
            %{
            hold on;
            if contains(plotShape,'proj','IgnoreCase', true)
                [Xpl, Ypl, Zpl] = sph2cart( ...
                    s.grid.theta_gr, ...
                    s.grid.phi_gr, ... % Daniel convention: elev. measured from north pole
                    ones(s.grid.res, s.grid.res));
                surf(Xpl,Ypl,Zpl,abs(sumCplx), ...
                    'edgealpha', 0.25);                            
            elseif contains(plotShape,'sph','IgnoreCase',true)
                [Xpl, Ypl, Zpl] = sph2cart( ...
                    s.grid.theta_gr, ...
                    s.grid.phi_gr, ... % Daniel convention: elev. measured from north pole
                    abs(sumCplx));
                surf(Xpl,Ypl,Zpl,abs(sumCplx), ...
                    'edgealpha', 0.25);            
            elseif contains(plotShape,'rec','IgnoreCase', true)
                surf(...
                    rad2deg(s.grid.theta_gr), ...
                    rad2deg(s.grid.phi_gr), ...
                    abs(sumCplx), ...
                    'edgealpha', 0);            
            end
            hold off;
            %}
            totalCplxSum = totalCplxSum + sumCplx;
        end
        %}
        
        
        if tt == 1
            fig = figure;
            if contains(plotShape, 'rec')
                Xpl = rad2deg(s.grid.theta_gr);
                Ypl = rad2deg(s.grid.phi_gr);
                Zpl = 20*log10(abs(totalCplxSum));
                sf = surf(Xpl, Ypl, Zpl, 'edgealpha', 0.5);
                caxis([-60,0]);
                zlim([-60,0]);
                view(2); axis tight;
                xlabel('Azi \theta'); ylabel('Elev. \delta');
                
            elseif contains(plotShape, 'proj')
                [Xpl,Ypl,Zpl] = sph2cart(...
                    s.grid.theta_gr, ...
                    s.grid.phi_gr, ...
                    ones(res,res));          
                    sf = surf(Xpl, Ypl, Zpl, 20*log10(abs(totalCplxSum)), 'edgealpha', 0.5);
                    caxis([-40,0]);
                    xlim([-1,1]); ylim([-1,1]); zlim([-1,1]);
                    axis square; camorbit(90,0,'data');
                    xlabel('x'); ylabel('y');
                    
            elseif contains(plotShape, 'sph')
                [Xpl,Ypl,Zpl] = sph2cart(...
                    s.grid.theta_gr, ...
                    s.grid.phi_gr, ...
                    abs(totalCplxSum));                 
                    sf = surf(Xpl, Ypl, Zpl, 'edgealpha', 0.5);
                    xlim([-1,1]); ylim([-1,1]); zlim([-1,1]);
                    axis square;
                    camorbit(90,0,'data');
                    xlabel('x'); ylabel('y');
            end
        else
            pause(0.005);
            if contains(plotShape, 'rec')
                sf.ZData = 20*log10(abs(totalCplxSum));

            elseif contains(plotShape, 'proj')
                sf.CData = 20*log10(abs(totalCplxSum));
                camorbit(0.5,0,'data')
            
            elseif contains(plotShape, 'sph')
                [sf.XData,sf.YData,sf.ZData] = sph2cart(...
                    s.grid.theta_gr, ...
                    s.grid.phi_gr, ...
                    abs(totalCplxSum));
                sf.CData = totalCplxSum;
                camorbit(0.5,0,'data')
            end
        end
    end
end