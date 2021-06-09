function s = beamsteer_init(s, inSigIdx, maskSigIdx)

    spkrCoords = s.beamsteer.spkrCoords;

    assert(numel(s.signal)>=max(inSigIdx,maskSigIdx), 'Invalid signal index');
    assert(numel(s.signal{inSigIdx})>0, 'Empty input signal');
    assert(size(spkrCoords,2)==2, 'Make sure angles are azi-elev pairs [deg]');
    assert(all(spkrCoords<=180,'all') && all(spkrCoords>=-180,'all'), ...
        'Make sure angles are in interval [-180,180] deg');
    
    % Initialize
    sigLen            = size(s.signal{inSigIdx},1);
    hoaWidth          = numel(s.harmonics)^2;
    spkrWidth         = size(spkrCoords,1);
    
    s.beamsteer.B_HO        = s.signal{inSigIdx}; % 1xM
    s.beamsteer.B_M         = s.signal{maskSigIdx}; % 1xM
    s.beamsteer.B_FO        = s.beamsteer.B_HO(:,1:4); % 1x4
    s.beamsteer.y           = zeros(sigLen,spkrWidth); % 1xS
    s.beamsteer.y_hat       = zeros(sigLen,spkrWidth); % 1xS
    s.beamsteer.err         = zeros(sigLen,spkrWidth);
    s.beamsteer.loss        = zeros(sigLen,1);
    s.beamsteer.D_HO        = zeros(hoaWidth, spkrWidth); % HOA to spkr, MxS
    s.beamsteer.D_FO        = zeros(4, spkrWidth); % FOA to spkr, 4xS
    s.beamsteer.D_FO_pinv   = zeros(sigLen,spkrWidth,4); % Sx4
    s.beamsteer.H           = zeros(sigLen,4,4); % 4x4
    s.beamsteer.Hstep_prev  = zeros(4,4);
    
    % Calculate Decoders (simple sampled)
    spkrCoordsRad = deg2rad([spkrCoords(:,1)-pi/2, spkrCoords(:,2)+pi/2]);
    
    for cc = 1:spkrWidth
        az_diff = (s.grid.theta - spkrCoordsRad(cc,1));
        el_diff = (s.grid.phi - spkrCoordsRad(cc,2));
        [az_mindiff, az_idx] = min(abs(az_diff));
        [el_mindiff, el_idx] = min(abs(el_diff));

        tolerance = 0.1*pi/180; % 0.1[deg]
%         if (az_mindiff < tolerance && el_mindiff < tolerance)
%             fprintf('Exact match found at [%.1f,%.1f]\n', ...
%                 rad2deg(s.grid.theta(az_idx)), ...
%                 rad2deg(s.grid.phi(el_idx)));
%         else
%             fprintf('Non-exact match found at [%.1f,%.1f]\n', ...
%                 rad2deg(s.grid.theta(az_idx)), ...
%                 rad2deg(s.grid.phi(el_idx)));
%         end
        
        channelIdx = 0;
        for mm_idx = 1:numel(s.harmonics)
            harmIdxs = channelIdx + (1:(mm_idx*2-1));
            
            s.beamsteer.D_HO(harmIdxs,cc) = squeeze(...
                s.harmonics(mm_idx).vert(:,el_idx,az_idx) ...
                .* s.harmonics(mm_idx).horz(:,el_idx,az_idx) ...
                .* s.harmonics(mm_idx).ordwt2 ...
                .* s.harmonics(mm_idx).harmwt);
            
            channelIdx = channelIdx + 2*mm_idx-1;
        end
    end
    
    s.beamsteer.D_FO = s.beamsteer.D_HO(1:4,:);
    
    % initial values
    D_FO = s.beamsteer.D_FO;
%     s.beamsteer.D_FO_pinv(1,:,:)   = D_FO'*inv(D_FO*D_FO' + s.beamsteer.beta0*eye(4)); % right inverse
    s.beamsteer.D_FO_pinv(1,:,:)    = (D_FO'*D_FO + s.beamsteer.beta0*eye(spkrWidth))\(D_FO'); % left inverse
%     s.beamsteer.H(1,:,:)            = eye(4);
    
    % pre-decode binaural outputs
    s.beamsteer.y           = s.beamsteer.B_M * s.beamsteer.D_HO;
    s.beamsteer.y_ho_bypass = s.beamsteer.B_HO * s.beamsteer.D_HO;
    s.beamsteer.y_fo_bypass = s.beamsteer.B_FO * s.beamsteer.D_FO;
end

