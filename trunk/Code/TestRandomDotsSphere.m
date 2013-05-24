clc
clear all
close all

vFov = 80/180*pi;
hFov = 240/180*pi;
vPx = 11;
hPx = 33;
aaCoef = 5;

[Phi Theta] = ndgrid(-linspace(-vFov/2,+vFov/2,vPx), ...
                     +linspace(-hFov/2,+hFov/2,hPx));
[PhiDelta ThetaDelta] = rank1Lattice(aaCoef);
PhiDelta    = PhiDelta * vFov/vPx;
ThetaDelta  = ThetaDelta * hFov/hPx;
nAa         = numel(PhiDelta);
nPx         = hPx * vPx;
Phi         = repmat(Phi(:),[1 nAa])    + repmat(PhiDelta(:)',[nPx 1]);
Theta       = repmat(Theta(:),[1 nAa])  + repmat(ThetaDelta(:)',[nPx 1]);
X = cos(Phi).*sin(Theta);
Y = sin(Phi);
Z = cos(Phi).*cos(Theta);

figure;
plot3(Z,X,Y,'.k');
