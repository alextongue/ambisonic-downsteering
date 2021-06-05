function lp = plotHarmonicSum(s, plotOrders, plotShape, plotCoeffs)

    maxOrd = (numel(s.harmonics)-1);
    if isempty(plotOrders)
        plotOrders = 0:maxOrd;
    end
    
    assert(all(plotOrders <= maxOrd) & all(plotOrders>=0), ...
        sprintf('Check order query (valid orders 0:%d)!',maxOrd));
    nCols = ceil(numel(plotOrders)/2);
    axhandles = [];
    
    totalMagSum = zeros(s.grid.res,s.grid.res);
    totalCplxSum = zeros(s.grid.res,s.grid.res);
    
    if any(contains(plotShape,{'sph','proj'},'IgnoreCase', true))
        viewDim = 3;
    elseif contains(plotShape,'rect','IgnoreCase', true)
        viewDim = 2;
    else
        error('Only {"sph","rect","proj"} plotshapes supported!');
    end
    
    fig1 = figure;
    for ii = 1:numel(plotOrders)

    subplot(2,nCols,ii);
        
        % sum together harmonics for a given order
        mm_idx = plotOrders(ii)+1;
        sumMag = zeros(s.grid.res, s.grid.res);
        sumCplx = zeros(s.grid.res, s.grid.res);
        
        for n_idx = 1:numel(s.harmonics(mm_idx).nn)
            if plotCoeffs
                currentCplx = ...
                    squeeze(s.harmonics(mm_idx).total(n_idx,:,:)) ...
                    .* s.harmonics(mm_idx).coeffs(n_idx);
            else
                currentCplx = ...
                    squeeze(s.harmonics(mm_idx).total(n_idx,:,:));
            end
            currentMag  = abs(currentCplx);
            
            sumCplx = sumCplx + currentCplx;
            sumMag = sumMag + currentMag;
        end
        
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
        xlabel('[x]');
        ylabel('[y]');
        zlabel('[z]');
        
    elseif contains(plotShape,'proj','IgnoreCase', true)    
        [Xpl, Ypl, Zpl] = sph2cart( ...
            s.grid.theta_gr, ...
            s.grid.phi_gr, ...
            ones(s.grid.res,s.grid.res));
        surf(Xpl,Ypl,Zpl,abs(totalCplxSum), ...
            'edgealpha', 0.25);
        xlabel('[x]');
        ylabel('[y]');
        zlabel('[z]');
        
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
%     if ~plotSuperpos
%         lp = linkprop(axhandles,{'CameraPosition', 'CameraTarget'});
%     end

end