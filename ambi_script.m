close all; clearvars; clc;
addpath('utils');

%%
data = genHarmonics(7, 100, 'n3d', 1000);

%%
data = addPlaneWave(data,[45,-20],0);
% data = addPlaneWave(data,[30,-0],-3);
% data = addPlaneWave(data,[55,20],0);

%%
%plotHarmonics(data, 0:7, true);
%plotHarmonicSum(data, 0:7, 'proj', true);
plotHarmonicSum(data, 0:7, 'sph', true);

%%
[xx,fs] = audioread('singletalk.wav');
xx = xx(1:10*fs);
data.fs = fs;
%%
data = encodeSignal(data, xx, [0,0], 0);

%%
animateCoefficients(data, 0:7);

%%
%make a masker
% make a rectangular visualization
% make an actual samplewise wrapper