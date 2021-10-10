close all; clearvars; clc;
addpath('utils');

%%
ord = 5;
data = genHarmonics(ord, 100, 'n3d', 1000);

%%
data = addStaticPlaneWave(data,[45,-20],0);
data = addStaticPlaneWave(data,[30,-0],-3);
data = addStaticPlaneWave(data,[55,20],0);

%%
%plotHarmonics(data, 0:7, true);
plotHarmonicSum(data, 0:ord, 'proj', true);

%%
[xx,fs] = audioread('singletalk.wav');
data.fs = fs;

xx0 = xx((5*fs+1):(8.5*fs));
xx1 = cat(1,zeros(2*fs,1), xx((5*fs+1):(8.5*fs)));
xx2 = cat(1,zeros(4*fs,1), xx((5*fs+1):(8.5*fs)));
xx3 = cat(1,zeros(6*fs,1), xx((5*fs+1):(8.5*fs)));
xx4 = cat(1,zeros(8*fs,1), xx((5*fs+1):(8.5*fs)));

%%
data = clearSignal(data);
data = encodeSignal(data, 1, xx0, [90,0], -6, true); 
data = encodeSignal(data, 1, xx1, [-90,0], -6, true);
data = encodeSignal(data, 1, xx2, [45,0], -6, true);
data = encodeSignal(data, 1, xx3, [-45,0], -6, false);

data = maskSignal(data, 1, 2, 'x');

%%
close all;
animateCoefficients(data, 1, 0:5, 1000, 'proj');

%%
close all;
fighandles = [];
%%
sweepParams = -36:-12:-60;
fighandles = [fighandles; figure];
for ii = 1:numel(sweepParams)
    fprintf('(%d of %d) param=%d\n', ii, numel(sweepParams), sweepParams(ii));
    data.beamsteer              = [];
    data.beamsteer.spkrCoords   = [20,0; -20,0; 30,0; -30,0; 90,0; -90,0];
    data.beamsteer.mu0          = 10^(sweepParams(ii)/20); % LMS:-80
    data.beamsteer.beta0        = 10^(-200/20); % LMS:-200
    data.beamsteer.alpha_step   = 10^(-12/20); % step decay (smaller = more smoothing) (LMS:-12)

    data = beamsteer_init(data, 2, 2);

    data.beamsteer = beamsteer(data.beamsteer, data.fs);
    
    plotString = sprintf('\\mu=%d dB', sweepParams(ii));
    plotConvergence(data.beamsteer, fighandles(end), plotString);
end
%%
% todo: improve H values shooting up
% todo: PAPER

%%
audiowrite('out_ho_masked.wav', data.beamsteer.y, data.fs);
audiowrite('out_fo_adapt.wav', data.beamsteer.y_hat, data.fs);
audiowrite('out_fo_byp.wav', data.beamsteer.y_fo_bypass, data.fs);
audiowrite('out_ho_byp.wav', data.beamsteer.y_ho_bypass, data.fs);
audiowrite('outhoa.wav', data.beamsteer.B_HO, data.fs);