function figHandle = plotConvergence(sb,figHandle,legendName)

    if isempty(figHandle)
        figHandle = figure;
    end
    if isempty(legendName)
%         legendName = ''
    end
%     figure; plot(10*log10(abs(data.beamsteer.err)));
    subplot(1,2,1);
    hold on;
    plot(20*log10(abs(sb.loss)), 'displayname', legendName);
    hold off;
    title('Function Loss'); ylabel('Loss [dB]'); xlabel('Sample');
    legend show;
    
    subplot(2,4,3); hold on; plot((sb.H(:,1,1))); hold off;
    subplot(2,4,4); hold on; plot((sb.H(:,1,2))); hold off;
    subplot(2,4,7); hold on; plot((sb.H(:,2,1))); hold off;
    subplot(2,4,8); hold on; plot((sb.H(:,2,2))); hold off;

end

