function s = clearSignal(s)
    if isfield(s.harmonics, 'coeffsig')
        s.harmonics = rmfield(s.harmonics,'coeffsig');
    end
    if isfield(s.harmonics, 'coeffsigMasked')
        s.harmonics = rmfield(s.harmonics,'coeffsigMasked');
    end
    
    s.signal = cell(1);
    
end

