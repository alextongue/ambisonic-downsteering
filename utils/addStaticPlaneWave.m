function s = addStaticPlaneWave(s,anglesDeg,gain_db)
%
%   Populates an ambisonic struct with a 'static' plane wave pressure
%   field. This can be called multiple times to superimpose multiple plane
%   waves. To clear plane waves, re-initialize the struct with
%   genHarmonics().
%
%   ARGUMENTS
%   s           [struct] Struct generated from genHarmonics()
%   
%   anglesDeg   [2x1 float] Ordered pair containing the desired azimuth and
%               elevation angle to which the static plane wave is placed.
%               Azimuth must be in the range [-180,+180] and elevation must
%               be in the range [-90,+90]
%
%   gain_db     [float] Gain to apply the plane wave amplitude

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
        fprintf('Non-exact match found at [%.1f,%.1f]\n', ...
            rad2deg(s.grid.theta(az_idx)), ...
            rad2deg(s.grid.phi(el_idx)));
    end
    
    for mm = 1:numel(s.harmonics)
        s.harmonics(mm).coeffs = ...
            s.harmonics(mm).coeffs ...
            + 10^(gain_db/20)*(squeeze(...
                s.harmonics(mm).vert(:,el_idx,az_idx) ...
                .* s.harmonics(mm).horz(:,el_idx,az_idx) ...
                .* s.harmonics(mm).ordwt2 ...
                .* s.harmonics(mm).harmwt)...
            );
        % coeffs must be normalized with harmwts first, then plotted
    end
    
end