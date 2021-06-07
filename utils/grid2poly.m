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
        mid_idx = mm+1;
        nn = (-mm:mm)';
        structOut(mid_idx).nn = nn;

        % Generate per-order weighting functions based on normalization
        structOut(mid_idx).ordwt1 = besselj(mm,kr);
        if strcmpi(normScheme, 'sn3d')
            structOut(mid_idx).ordwt2  = sqrt( 1/(4*pi) );
        elseif strcmpi(normScheme,'n3d')
            structOut(mid_idx).ordwt2  = sqrt( (2*mm+1)/(4*pi) );
        else
            error('only SN3D and N3D normalizations supported!');
        end

        % Generate weights per-harmonic (within order)
        wt_a                            = factorial(mm-abs(nn));
        wt_b                            = factorial(mm+abs(nn));
        structOut(mid_idx).harmwt        = sqrt((2-(nn==0)).*wt_a./wt_b);
        structOut(mid_idx).harmwt_rep   = ...
            repmat(structOut(mid_idx).harmwt, 1, res, res);

        % Generate vertical term (Legendre polynomial)
        % cospoly = legendre(mm,cosphi_gr,'unnorm'); % not used by polarch
        sinpoly = legendre(mm,sinphi_gr,'unnorm');
        if mm == 0
            structOut(mid_idx).vert = reshape(sinpoly,1,res,res);
        else
            structOut(mid_idx).vert = repmat(((-1).^nn),1,res,res) ...
                .* cat(1, flip(sinpoly(2:end,:,:),1), sinpoly);
        end

        % Generate horizontal term (complex exponential)
        tmp_horz                    = ones(numel(nn),res,res);
        if mm ~= 0
            azGridRep                   = reshape(azGrid,1,res,res);
            tmp_horz(mid_idx:end,:,:)   = real(exp(1i.*nn(mid_idx:end).*azGridRep));
            tmp_horz(1:mm,:,:)          = imag(exp(1i.*nn(1:mm).*azGridRep));
        end
        
        structOut(mid_idx).horz            = tmp_horz;
        structOut(mid_idx).total           = ... %structOut(mm_idx).ordwt1 ...
            structOut(mid_idx).ordwt2 ...
            .* structOut(mid_idx).harmwt ...
            .* structOut(mid_idx).vert ...
            .* structOut(mid_idx).horz;
        structOut(mid_idx).coeffs          = zeros(size(nn)); % init
        
    end
end