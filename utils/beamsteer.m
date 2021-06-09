function sb = beamsteer(sb,fs)
%     assert(numel(s.signal)>=max(inSigIdx,maskSigIdx), 'Invalid signal index');
%     assert(numel(s.signal{inSigIdx})>0, 'Empty input signal');
%     assert(numel(s.signal{maskSigIdx})>0, 'Empty mask signal');
%     assert(all(size(s.signal{inSigIdx})==size(s.signal{maskSigIdx})), 'Signal sizes must be equal');
    
    sigLen = size(sb.y,1);
    for tt = 1:(sigLen-1)
%         if mod(tt,fs)==0
%             fprintf('frame %d (t=%.4f)\n', tt, tt/fs);
%         end
        sb.y_hat(tt,:) = ...
            sb.B_FO(tt,:) * squeeze(sb.H(tt,:,:)) * sb.D_FO;
        sb.err(tt,:)   = sb.y(tt,:) - sb.y_hat(tt,:);
        sb.loss(tt,:)  = (sb.err(tt,:) * sb.err(tt,:)')/size(sb.spkrCoords,1);
        
        % update filter
        inputPwr = sb.B_FO(tt,:) * sb.B_FO(tt,:)';
        if inputPwr<1e-12
            inputPwr = 1e-12;
        end
        currentStep = ...
            (sb.alpha_step)*((squeeze(sb.D_FO_pinv(1,:,:))' * sb.err(tt,:)') ...
            * sb.B_FO(tt,:)) ...
            + (1-sb.alpha_step)*sb.Hstep_prev;
%         currentStep = ...
%             ((squeeze(sb.D_FO_pinv(1,:,:))' * sb.err(tt,:)') ...
%             * sb.B_FO(tt,:)) ...
%             + sb.Hstep_prev;
%         currentStep = currentStep * inputPwr;
        sb.Hstep_prev = currentStep;

        sb.H(tt+1,:,:) = squeeze(sb.H(tt,:,:)) + sb.mu0*currentStep;
%         sb.H(tt+1,:,:) = squeeze(sb.H(tt,:,:)) + sb.mu0*currentStep./inputPwr;
    end
    
end

