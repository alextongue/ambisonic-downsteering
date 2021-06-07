close all; clearvars; clc;
addpath('utils');

%%
data = genHarmonics(7, 100, 'n3d', 1000);

%%
data = addPlaneWave(data,[45,-20],0);
data = addPlaneWave(data,[30,-0],-3);
data = addPlaneWave(data,[55,20],0);

%%
%plotHarmonics(data, 0:7, true);
%plotHarmonicSum(data, 0:7, 'proj', true);
plotHarmonicSum(data, 0:7, 'sph', true);

%%
[xx,fs] = audioread('singletalk.wav');
data.fs = fs;
xx1 = xx((2*fs+1):(7*fs));
xx2 = xx((2.5*fs+1):(7*fs));
xx3 = xx((3*fs+1):(7*fs));
%%
data = clearSignal(data);
data = encodeSignal(data, 1, xx1, [0,0], 0, false);
data = encodeSignal(data, 1, xx2, [45,0], -12, false);
data = encodeSignal(data, 1, xx3, [-90,-20], 0, false);

%%
close all;
animateCoefficients(data, 1, 0:7, 1000, 'proj');

%%
%make a masker
data = maskSignal(data, 2, 'x');

% todo: put entire ambisonic signal into matrix form
% todo: make inversions and calculate error wrt. frame