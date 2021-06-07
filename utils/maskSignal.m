function s = maskSignal(s, srcSigIdx, destSigIdx, maskType)

    assert(isfield(s.harmonics, 'coeffsig'),'No Ambisonic signal found');
    assert(size(s.signal{srcSigIdx},1)>0, 'Empty signal')

    concatMask = [];
    for mm = 1:numel(s.harmonics)
        switch maskType
            case 'x'
                if mm==1
                    ambiMask = 1;
                else
                    centerIdx = mm+1;
                    nn = s.harmonics(mm).nn;
                    posMask = mod(nn(mm:end), 2) == 1;
                    negMask = mod(nn(1:(mm-1)), 2) == 0;
                    ambiMask = cat(2,negMask(:)',posMask(:)');
                end
                concatMask = cat(2,concatMask, ambiMask);
            otherwise
                error('Mask type not supported');
        end
    end
    
    s.signal{destSigIdx} = s.signal{srcSigIdx} .* concatMask;
end
