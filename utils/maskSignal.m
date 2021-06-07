function s = maskSignal(s, signalIdx, maskType)

assert(isfield(s.harmonics, 'coeffsig'),'No Ambisonic signal found');

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
            s.harmonics(mm).coeffsigMasked = ...
                s.harmonics(mm).coeffsig .* ambiMask;
            pause(0.01);
        otherwise
            error('Mask type not supported');
    end

end

