close all; clearvars; clc;
addpath('utils');

%%
data = genHarmonics(5, 100, 'n3d', 1000);

%%
data = addStaticPlaneWave(data,[45,-20],0);
data = addStaticPlaneWave(data,[30,-0],-3);
data = addStaticPlaneWave(data,[55,20],0);

%%
%plotHarmonics(data, 0:7, true);
%plotHarmonicSum(data, 0:7, 'proj', true);
plotHarmonicSum(data, 0:5, 'sph', true);

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
data = encodeSignal(data, 1, xx0, [0,0], -6, true); 
data = encodeSignal(data, 1, xx1, [90,0], -6, true); 
data = encodeSignal(data, 1, xx2, [-90,0], -6, true);
data = encodeSignal(data, 1, xx3, [45,0], -6, false);
data = encodeSignal(data, 1, xx4, [-45,0], -6, false);

data = maskSignal(data, 1, 2, 'x');
fighand = figure;
%%
close all;
animateCoefficients(data, 1, 0:5, 5000, 'proj');

%%
data.beamsteer              = [];
% data.beamsteer.spkrCoords   = [90,0; -90,0];
data.beamsteer.spkrCoords   = [90,0; -90,0; 30,0; -30,0; 20,0; -20,0];
data.beamsteer.mu0          = 10^(-40/20);
data.beamsteer.beta0        = 10^(-200/20);
data.beamsteer.alpha_step   = 10^(-120/20); % step decay (smaller = more smoothing)

data = beamsteer_init(data, 1, 2);
%%
data.beamsteer = beamsteer(data.beamsteer, data.fs);
%%

plotConvergence(data.beamsteer,fighand,'\mu=-40dB, \beta=-200dB, \alpha=-120dB');