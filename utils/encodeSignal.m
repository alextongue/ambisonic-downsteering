function s = encodeSignal(s, sigIdx, xx, angleDeg, gain_db, extendSignal)
    
    angleRad = deg2rad([angleDeg(1), angleDeg(2)+pi/2]);
    assert(numel(angleDeg)==2, 'Angle dimension error');
    assert(angleRad(1)>= s.grid.theta(1) && angleRad(1) <= s.grid.theta(end), 'Azimuth out of bounds');
    assert(angleRad(2)>= s.grid.phi(1) && angleRad(2) <= s.grid.phi(end), 'Elevation out of bounds');
    assert(size(xx,2)==1, 'Signal must be mono');
    assert(gain_db <= 0, 'Gain must be nonpositive [dB]');
        
    % Find index
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
    
    if ~isfield(s.harmonics, 'coeffsig')
        for mm_idx = 1:numel(s.harmonics)
            s.harmonics(mm_idx).coeffsig = zeros(size(xx,1),numel(s.harmonics(mm_idx).nn));
        end
        fprintf('CoeffSigs initialized to %d samps\n', size(xx,1));
    end
    
        
    % (1) ENCODE AND STORE SIGNAL, BY SH ORDER
    sigLen = size(xx,1);
    for mm_idx = 1:numel(s.harmonics)
        encodeMtx = ...
            10^(gain_db/20)*(squeeze(...
            s.harmonics(mm_idx).vert(:,el_idx,az_idx) ...
            .* s.harmonics(mm_idx).horz(:,el_idx,az_idx) ...
            .* s.harmonics(mm_idx).ordwt2 ...
            .* s.harmonics(mm_idx).harmwt));
        storedLen = size(s.harmonics(mm_idx).coeffsig,1);
        if sigLen>storedLen
            if extendSignal
                s.harmonics(mm_idx).coeffsig((storedLen+1):sigLen,:) = 0;
                fprintf('CoeffSigs extended to %d samps\n', sigLen);
            else
                xx = xx(1:storedLen);
            end
        elseif sigLen<storedLen
            xx(sigLen:storedLen) = 0;
        end

        s.harmonics(mm_idx).coeffsig = ...
            s.harmonics(mm_idx).coeffsig + xx(:)*encodeMtx(:)';
    end
    
%     s.sigLen = size(s.harmonics(1).coeffsig,1);
    
    % (2) STORE SIGNAL AS MATRIX
    mtxLen = size(s.harmonics(1).coeffsig,1);
    temp_sigmtx = zeros(mtxLen, numel(s.harmonics)^2);
    channelIdx = 0;
    
    % (Concatenate)
    for mm_idx = 1:numel(s.harmonics)
        harmIdxs = channelIdx + (1:(mm_idx*2-1));
        temp_sigmtx(:,harmIdxs) = s.harmonics(mm_idx).coeffsig;
        channelIdx = channelIdx + 2*mm_idx-1;
    end
    
    % (Store)
    if isempty(s.signal{sigIdx})
        s.signal{sigIdx} = temp_sigmtx;
    else
        storedLen = size(s.signal{sigIdx},1);
        if mtxLen>storedLen
            if extendSignal
                s.signal{sigIdx}((storedLen+1):mtxLen,:) = 0;
            else
                temp_sigmtx = temp_sigmtx(1:storedLen);
            end
        elseif mtxLen<storedLen
            temp_sigmtx(mtxLen:storedLen) = 0;
        end
        s.signal{sigIdx} = s.signal{sigIdx} + temp_sigmtx;
    end
    
end