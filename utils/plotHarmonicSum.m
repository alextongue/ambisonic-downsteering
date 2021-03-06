function lp = plotHarmonicSum(s, plotOrders, plotShape, plotStaticCoeffs)

    maxOrd = (numel(s.harmonics)-1);
    if isempty(plotOrders)
        plotOrders = 0:maxOrd;
    end
    
    assert(all(plotOrders <= maxOrd) & all(plotOrders>=0), ...
        sprintf('Check order query (valid orders 0:%d)!',maxOrd));
    nCols = ceil(numel(plotOrders)/2);
    res = s.grid.res;
    axhandles = [];
    
    if any(contains(plotShape,{'sph','proj'},'IgnoreCase', true))
        viewDim = 3;
    elseif contains(plotShape,'rec','IgnoreCase', true)
        viewDim = 2;
    else
        error('Only {"sph","rec","proj"} plotshapes supported!');
    end
    
    totalMagSum = zeros(s.grid.res,s.grid.res);
    totalCplxSum = zeros(s.grid.res,s.grid.res);
    
    fig1 = figure;
    for ii = 1:numel(plotOrders)

    subplot(2,nCols,ii);
        
        % sum together harmonics for a given order
        mm_idx = plotOrders(ii)+1;
        sumMag = zeros(s.grid.res, s.grid.res);
        sumCplx = zeros(s.grid.res, s.grid.res);
        
        if plotStaticCoeffs
            sumCplx = ...
                squeeze( sum(s.harmonics(mm_idx).total ...
                .* repmat(s.harmonics(mm_idx).coeffs, 1, res, res),...
                1) );
        else
            sumCplx = squeeze( sum(s.harmonics(mm_idx).total,1) );
        end
        
        hold on;
        if contains(plotShape,'proj','IgnoreCase', true)
            [Xpl, Ypl, Zpl] = sph2cart( ...
                s.grid.theta_gr, ...
                s.grid.phi_gr, ... % Daniel convention: elev. measured from north pole
                ones(s.grid.res, s.grid.res));
            surf(Xpl,Ypl,Zpl,(sumCplx), ...
                'edgealpha', 0.25);
            
        elseif contains(plotShape,'sph','IgnoreCase',true)
            [Xpl, Ypl, Zpl] = sph2cart( ...
                s.grid.theta_gr, ...
                s.grid.phi_gr, ... % Daniel convention: elev. measured from north pole
                abs(sumCplx));
            surf(Xpl,Ypl,Zpl,(sumCplx), ...
                'edgealpha', 0.25);
            
        elseif contains(plotShape,'rec','IgnoreCase', true)
            surf(...
                rad2deg(s.grid.theta_gr), ...
                rad2deg(s.grid.phi_gr), ...
                (sumCplx), ...
                'edgealpha', 0);
        end
        hold off;
        
        axhandles = [axhandles,gca()];
        
        totalMagSum = totalMagSum + sumMag;
        totalCplxSum = totalCplxSum + sumCplx;
        title(sprintf('m=%d', mm_idx-1));
        axis image;
        view(viewDim);
        grid on;
    end
    
    fig2 = figure;
    if contains(plotShape,'sph','IgnoreCase', true)
        [Xpl, Ypl, Zpl] = sph2cart( ...
            s.grid.theta_gr, ...
            s.grid.phi_gr, ...
            abs(totalCplxSum));
        surf(Xpl,Ypl,Zpl,abs(totalCplxSum), ...
            'edgealpha', 0.25);
        xlabel('[x]'); ylabel('[y]'); zlabel('[z]');
        
    elseif contains(plotShape,'proj','IgnoreCase', true)    
        [Xpl, Ypl, Zpl] = sph2cart( ...
            s.grid.theta_gr, ...
            s.grid.phi_gr, ...
            ones(s.grid.res,s.grid.res));
        surf(Xpl,Ypl,Zpl,abs(totalCplxSum), ...
            'edgealpha', 0.25);
        xlabel('[x]'); ylabel('[y]'); zlabel('[z]');
        
    elseif contains(plotShape,'rec','IgnoreCase', true)
        surf(...
            rad2deg(s.grid.theta_gr), ...
            rad2deg(s.grid.phi_gr), ...
            abs(totalCplxSum), ...
            'edgealpha', 0)
        xlabel('Azi \theta');
        ylabel('Elev. \delta');
    end

    title( sprintf('Fourier-Bessel Sum') );
    axis image;
    view(viewDim);
    grid on;

end