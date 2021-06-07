function s = addStaticPlaneWave(s,anglesDeg,gain_db)

    assert(numel(anglesDeg)==2, ...
        'Make sure angle is an azi-elev vector [deg]');
    assert(all(anglesDeg<=180) && all(anglesDeg>=-180), ...
        'Make sure angles are in interval [-180,180] deg');
    if isempty(gain_db)
        gain_db=0;
    end
    
    anglesRad = deg2rad([anglesDeg(1), anglesDeg(2)+pi/2]);
    
    az_diff = (s.grid.theta - anglesRad(1));
    el_diff = (s.grid.phi - anglesRad(2));
    [az_mindiff, az_idx] = min(abs(az_diff));
    [el_mindiff, el_idx] = min(abs(el_diff));
    
    tolerance = 0.1*pi/180; % in radians
    
    if (az_mindiff < tolerance && el_mindiff < tolerance)
        fprintf('Exact match found at [%.1f,%.1f]\n', ...
            rad2deg(s.grid.theta(az_idx)), ...
            rad2deg(s.grid.phi(el_idx)));
    else
        fprintf('Non-exact match found at [%.1f,%.1f] (diff [%.4f, %.4f] deg)\n', ...
            rad2deg(s.grid.theta(az_idx)), ...
            rad2deg(s.grid.phi(el_idx)), ...
            rad2deg(az_diff(az_idx)), ...
            rad2deg(el_diff(el_idx)));
    end
    
%     srcGrid             = s.grid;
%     srcGrid.theta       = anglesDeg(1)*ones(s.grid.res,1);
%     srcGrid.phi         = anglesDeg(2)*ones(s.grid.res,1);
%     srcGrid.theta_gr    = anglesDeg(1)*ones(s.grid.res,s.grid.res);
%     srcGrid.phi_gr      = anglesDeg(2)*ones(s.grid.res,s.grid.res);
%     s.harmonics = grid2poly(srcGrid, ord_l, normScheme);
    
    for mm = 1:numel(s.harmonics)
        s.harmonics(mm).coeffs = ...
            s.harmonics(mm).coeffs ...
            + 10^(gain_db/20)*(squeeze(...
            s.harmonics(mm).vert(:,el_idx,az_idx) ...
            .* s.harmonics(mm).horz(:,el_idx,az_idx) ...
            .* s.harmonics(mm).ordwt2 ...
            .* s.harmonics(mm).harmwt));
        % coeffs must be normalized with harmwts first, then plotted
    end
    
end