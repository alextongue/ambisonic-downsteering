function s = beamsteer(s, inSigIdx, maskSigIdx)
    assert(numel(s.signal)>=max(inSigIdx,maskSigIdx), 'Invalid signal index');
    assert(numel(s.signal{inSigIdx})>0, 'Empty input signal');
    assert(numel(s.signal{maskSigIdx})>0, 'Empty mask signal');
    assert(all(size(s.signal{inSigIdx})==size(s.signal{maskSigIdx})), 'Signal sizes must be equal');
    
    for tt = 1:sigLen
        b_ho    = B_HO(tt,:)';
        b_m     = B_M(tt,:)';
        b_fo    = B_FO(tt,:)';
    end
    
end

