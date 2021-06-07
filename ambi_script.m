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

%%
data = clearSignal(data);
data = encodeSignal(data, 1, xx((2*fs+1):(7*fs)), [0,0], 0, false);
data = encodeSignal(data, 1, xx((2.5*fs+1):(7*fs)), [45,0], -12, false);
data = encodeSignal(data, 1, xx((3*fs+1):(7*fs)), [-90,-20], 0, false);

data = maskSignal(data, 1, 2, 'x');

%%
close all;
animateCoefficients(data, 1, 0:5, 1000, 'proj');

%%
data.beamsteer.spkrCoords   = [-30,0; -20,0; 20,0; 30,0];
data.beamsteer.mu           = 0.1;
data.beamsteer.beta         = 0.01;

data = beamsteer_init(data, 1, 2);
% data = beamsteer(data);

% TODO:
%   dbl check mtx dimensions
%   begin inversion process and calculate error wrt. frame