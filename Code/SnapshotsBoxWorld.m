clc
clear all
clear classes
close all

% *************************************************************************
% A simple box world to test the camera models, texture mapping, and light
% model within the ray-tracer.
%   Florian Raudies, 06/10/2013, Boston University.
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
scene       = Scene;
GroundPlane = Plane(1,1,[-w/2; 0; +l/2],[-w/2; 0; -l/2],[+w/2; 0; -l/2]);
LeftWall    = Plane(2,3,[-w/2; 0; +l/2],[-w/2; h; +l/2],[-w/2; h; -l/2]);
RightWall   = Plane(3,2,[+w/2; 0; +l/2],[+w/2; 0; -l/2],[+w/2; h; -l/2]);
TopWall     = Plane(4,2,[-w/2; 0; +l/2],[+w/2; 0; +l/2],[+w/2; h; +l/2]);
DownWall    = Plane(5,2,[-w/2; 0; -l/2],[-w/2; h; -l/2],[+w/2; h; -l/2]);
% Add primitives.
scene.addObject(GroundPlane);
scene.addObject(LeftWall);
scene.addObject(RightWall);
scene.addObject(TopWall);
scene.addObject(DownWall);
% Add materials.
scene.addMaterial(Texture2D(1,'../Textures/Checkerboard.png',3,1));
scene.addMaterial(Texture2D(2,'../Textures/DotPattern.png',2,20/15));
scene.addMaterial(Texture2D(3,'../Textures/ColorDotPattern.png',2,20/15));
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
