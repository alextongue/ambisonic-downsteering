function structOut = grid2poly(gridStruct, ord_l, normScheme)

    azGrid  = gridStruct.theta_gr;
    elGrid  = gridStruct.phi_gr;
    res     = gridStruct.res;
    kr      = gridStruct.kr;

    assert(all(size(azGrid)==size(elGrid)), 'Grids must be equal size.');
    assert(numel(size(azGrid))==2, 'Grids must be 2D.');
    assert(size(azGrid,1)==size(azGrid,2),'Grids must be square');

    % cosine transformation of elevation
    cosphi_gr = cos(elGrid);
    sinphi_gr = sin(elGrid);

    for mm = 0:(ord_l)

        % Generate range of of harmonics for a given order
        mm_idx = mm+1;
        nn = (-mm:mm)';
        structOut(mm_idx).nn = nn;

        % Generate per-order weighting functions based on normalization
        structOut(mm_idx).ordwt1 = besselj(mm,kr);
        if strcmpi(normScheme, 'sn3d')
            structOut(mm_idx).ordwt2  = 1;
        elseif strcmpi(normScheme,'n3d')
            structOut(mm_idx).ordwt2  = sqrt(2*mm+1);
        else
            error('only SN3D and N3D normalizations supported!');
        end

        % Generate weights per-harmonic (within order)
        wt_a                            = factorial(mm-abs(nn));
        wt_b                            = factorial(mm+abs(nn));
        structOut(mm_idx).harmwt        = sqrt((2-(nn==0)).*wt_a./wt_b);
        structOut(mm_idx).harmwt_full   = ...
            repmat(structOut(mm_idx).harmwt, ...
            1, res, res);

        % Generate vertical term (Legendre polynomial)
        cospoly = legendre(mm,cosphi_gr,'unnorm');
        sinpoly = legendre(mm,sinphi_gr,'unnorm');
        if mm == 0
            structOut(mm_idx).vert = reshape(sinpoly,1,res,res);
        else
            structOut(mm_idx).vert = cat(1, flip(sinpoly(2:end,:,:),1), sinpoly);
        end

        % Generate horizontal term (complex exponential)
        tmp_horz                    = zeros(mm_idx,res,res);
        for m_idx = 1:numel(nn)
            if nn(m_idx) >= 0
                tmp_horz(m_idx,:,:) = real(exp(1i.*nn(m_idx)*azGrid));
            else
                tmp_horz(m_idx,:,:) = imag(exp(1i.*nn(m_idx)*azGrid));
            end
        end
        
        structOut(mm_idx).horz            = tmp_horz;
        structOut(mm_idx).total           = ...
            structOut(mm_idx).ordwt1 ...
            .* structOut(mm_idx).ordwt2 ...
            .* structOut(mm_idx).harmwt_full ...
            .* structOut(mm_idx).vert ...
            .* structOut(mm_idx).horz;
        structOut(mm_idx).coeffs          = zeros(size(nn)); % init
        
    end
end