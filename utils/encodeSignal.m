function s = encodeSignal(s, inSig, angleDeg, gain_db)
    
    % find index    
    angleRad = deg2rad([angleDeg(1), angleDeg(2)+pi/2]);

    assert(numel(angleDeg)==2, 'Angle dimension error');
    assert(angleRad(1)>= s.grid.theta(1) && angleRad(1) <= s.grid.theta(end), 'Azimuth out of bounds');
    assert(angleRad(2)>= s.grid.phi(1) && angleRad(2) <= s.grid.phi(end), 'Elevation out of bounds');
    assert(size(inSig,2)==1, 'Signal must be mono');
    assert(gain_db <= 0, 'gain must be nonpositive');
        
    az_diff = (s.grid.theta - angleRad(1));
    el_diff = (s.grid.phi - angleRad(2));
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
    
    % encode
    for mm = 1:numel(s.harmonics)
        encodeMtx = ...
            10^(gain_db/20)*(squeeze(...
            s.harmonics(mm).vert(:,el_idx,az_idx) ...
            .* s.harmonics(mm).horz(:,el_idx,az_idx) ...
            .* s.harmonics(mm).ordwt2 ...
            .* s.harmonics(mm).harmwt));        
        s.harmonics(mm).coeffsig = inSig(:) * encodeMtx(:)';
    end
    
    s.sigLen = size(s.harmonics(1).coeffsig,1);
    
end