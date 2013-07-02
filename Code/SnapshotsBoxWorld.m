clc
clear all
clear classes
close all

% *************************************************************************
% A simple box world to test the camera models, texture mapping, and light
% model within the ray-tracer.
%   Florian Raudies, 07/02/2013, Boston University.
% *************************************************************************

% *************************************************************************
% Dimensions of the box.
% *************************************************************************
w = 200;    % cm width of box
l = 200;    % cm length of box
h = 150;    % cm height of box

% *************************************************************************
% Construct a box scene from five planes, one texture, and one camera.
% *************************************************************************
scene   = BoxWorld(w,l,h);
% Add pinhole camera.
scene.addCamera(PinholeCamera(1,[0;0;1;0],[0;1;0;0],[0;20;-80;0],...
                                80/180*pi,80/180*pi,150,150,5,[0 10^3]));
scene.addCamera(SphericalCamera(1,[0;0;1;0],[0;1;0;0],[0;20;-80;0],...
                                240/180*pi,80/180*pi,225,75,5,[0 10^3]));
scene.addLight(Light(1,[-80; 50; 0; 0],[50 20 210],[1 0.5 .5],[1 1 1],10^3));
scene.initialize();

view.Point  = [50 20 -30 0];
M           = rotationMatrix([0 0 0]); %rotationMatrix([0 325/180*pi 0]);
view.Dir    = M*[0 0 1 0]';
view.Up     = M*[0 1 0 0]';

% *************************************************************************
% Snapshot for pinhole camera.
% *************************************************************************
cameraId    = 1;
scene.moveCameraTo(cameraId,view.Point);
scene.orientCamera(cameraId,view.Dir,view.Up);
[Img Z] = scene.rayTrace(cameraId);

figure;
subplot(1,2,1); imshow(Z,[]);
subplot(1,2,2); image(Img/max(Img(:))); axis off equal;


% *************************************************************************
% Snapshot for sherical camera.
% *************************************************************************
cameraId    = 2;
scene.moveCameraTo(cameraId,view.Point);
scene.orientCamera(cameraId,view.Dir,view.Up);
[Img Z] = scene.rayTrace(cameraId);

figure;
subplot(2,1,1); imshow(Z,[]);
subplot(2,1,2); image(Img/max(Img(:))); axis off equal;
