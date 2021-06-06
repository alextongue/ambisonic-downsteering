function lp = plotHarmonics(s, plotOrders, plotCoeffs)

    maxOrder = (numel(s.harmonics)-1);
    assert(all(plotOrders <= maxOrder) & all(plotOrders>=0), ...
        sprintf('Check order query (valid orders 0:%d)!',maxOrder));
    mm = plotOrders;
    nCols = ceil(numel(mm)/2);
    axhandles = [];
    
    fig1 = figure;
    for ii = 1:numel(mm)

        subplot(2,nCols,ii);
        mm_idx = mm(ii)+1;
        for n_idx = 1:numel(s.harmonics(mm_idx).nn)
            
            if plotCoeffs
                currentCplx = ...
                    squeeze(s.harmonics(mm_idx).total(n_idx,:,:)) ...
                    .* s.harmonics(mm_idx).coeffs(n_idx);
            else
                currentCplx = ...
                    squeeze(s.harmonics(mm_idx).total(n_idx,:,:));
            end

            %currentMag  = abs(currentCplx);
            currentSign = (sign(currentCplx));
            hold on;
            
            [Xpl, Ypl, Zpl] = sph2cart( ...
                s.grid.theta_gr, ...
                s.grid.phi_gr, ... % Daniel convention: elev. measured from north pole
                abs(currentCplx));
            surf(Xpl,Ypl,Zpl,currentSign, ... 
                'edgealpha', 0.25, 'facealpha', 0.7);

            hold off;
        end
        title(sprintf('m=%d', mm_idx-1));
        axis image;
        view(3);
        grid on;
        axhandles = [axhandles; gca()];
    end

end