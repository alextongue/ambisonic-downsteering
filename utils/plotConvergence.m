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
    pl = plot(20*log10(abs(sb.loss)), ...
        'linewidth', 1, ...
        'displayname', legendName);
    pl.Color(4) = 0.1;
    hold off;
    grid on;
    title('Function Loss (MSE)'); ylabel('Loss [dB]'); xlabel('Sample');
    
    for rr = 1:4
        for cc = 1:4
            pltIdx = (rr-1)*8+4+cc;
            subplot(4,8,pltIdx)
            hold on;
            plot(20*log10(abs(sb.H(:,rr,cc))), ...
                'linewidth', 2, ...
                'displayname', legendName);
            ylim([-100,10]);
            title(sprintf('(%d,%d)',rr,cc));
            hold off;
            grid on;
            if all([rr,cc]==1)
                legend show;
            end
        end
    end
    

end
%%
% 
% figure(2)
% % subplot(1,2,1);
% % xlim([0,24000]);
% 
% for rr = 1:4
%     for cc = 1:4
%         pltIdx = (rr-1)*8+4+cc;
%         subplot(4,8,pltIdx)
%         ylim([-120,40]);
%     end
% end
