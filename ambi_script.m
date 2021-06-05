close all; clearvars; clc;

%%
data = genHarmonics(7, 100, 'n3d', 1000);

%%
data = addPlaneWave(data,[45,-20],0);
data = addPlaneWave(data,[30,-0],-3);
data = addPlaneWave(data,[55,20],0);

%%
plotHarmonics(data, 0:7, true);
plotHarmonicSum(data, 0:7, 'proj', true);
plotHarmonicSum(data, 0:7, 'sph', false);

%%
%make a masker
% make a rectangular visualization
% make an actual samplewise wrapper
%%
%{
xrange  = [-1,1];
xtic    = 2/res;
xx      = (-1+xtic):xtic:1;

legendre_man = zeros(numel(xx),5);
legendre_man(:,1) = ones(size(xx));
legendre_man(:,2) = xx;
legendre_man(:,3) = (1/2)*(3*xx.^2 - 1);
legendre_man(:,4) = (1/2)*(5*xx.^3 - 3.*xx);
legendre_man(:,5) = (1/8)*(35*xx.^4 - 30*xx.^2 + 3);

legendre_aut = legendre(4,xx,'norm')';

figure;
subplot(2,2,1);
plot(xx, legendre_man(:,1),'linewidth',1.5); hold on;
for pp = 2:size(legendre_man,2)
    plot(xx, legendre_man(:,pp),'linewidth',1.5);
end
hold off;

subplot(2,2,3);
plot(xx, legendre_aut(:,1),'linewidth',1.5); hold on;
for pp = 1:size(legendre_aut,2)
    plot(xx, legendre_aut(:,pp),'linewidth',1.5);
end
hold off;

subplot(2,2,2);
polarplot(theta, legendre_man(:,1),'linewidth',1.5); hold on;
for pp = 2:size(legendre_man,2)
    polarplot(theta, legendre_man(:,pp),'linewidth',1.5);
end
%}
