clc
clear all
clear classes
close all
TITLE_SIZE = 18;

% *************************************************************************
% A simple box world to test the ray-tracer.
%   Florian Raudies, 05/22/2013, Boston University.
% *************************************************************************


% *************************************************************************
% Dimensions of the box.
% *************************************************************************
w = 200;    % cm width of box
l = 200;    % cm length of box
h = 150;     % cm height of box

% *************************************************************************
% Pinhole Camera
% *************************************************************************
Dir     = [0 0 1 0]';
Up      = [0 1 0 0]';
Pos     = [10 20 -80 0]';
hFov    = 80/180*pi;
vFov    = 80/180*pi;
hPx     = 50;
vPx     = 50;

% *************************************************************************
% Construct a box scene from five planes, one texture, and one camera.
% *************************************************************************
scene       = Scene;
GroundPlane = Plane(1,1,[-w/2; 0; +l/2],[-w/2; 0; -l/2],[+w/2; 0; -l/2]);
LeftWall    = Plane(2,3,[-w/2; 0; +l/2],[-w/2; h; +l/2],[-w/2; h; -l/2]);
RightWall   = Plane(3,2,[+w/2; 0; +l/2],[+w/2; h; +l/2],[+w/2; h; -l/2]);
TopWall     = Plane(4,2,[-w/2; 0; +l/2],[-w/2; h; +l/2],[+w/2; h; +l/2]);
DownWall    = Plane(5,2,[-w/2; 0; -l/2],[-w/2; h; -l/2],[+w/2; h; -l/2]);
% Add primitives.
scene = scene.addPrimitive(GroundPlane);
scene = scene.addPrimitive(LeftWall);
scene = scene.addPrimitive(RightWall);
scene = scene.addPrimitive(TopWall);
scene = scene.addPrimitive(DownWall);
% Add materials.
scene = scene.addMaterial(Texture2D(1,'../Textures/Checkerboard.png',6));
scene = scene.addMaterial(Texture2D(2,'../Textures/DotPattern.png',3));
scene = scene.addMaterial(Texture2D(3,'../Textures/ColorDotPattern.png',3));
scene = scene.addCamera(PinholeCamera(1,Dir,Up,Pos,hFov,vFov,hPx,vPx,[0 10^3]));
scene = scene.initialize();
% scene = scene.rotateCamera(1,[0 pi/4 0]);
% scene = scene.moveByCamera(1,[0 5 0 0]');

% *************************************************************************
% Ray trace to generate the image and depth map (zBuffer).
% *************************************************************************
[Img Z] = scene.rayTrace(1); % cameraId is one.

% *************************************************************************
% Display the depth map and image.
% *************************************************************************
figure;
subplot(1,2,1); 
    imshow(log(Z),[0 log(200)], 'XData',scene.cameras(1).ScreenX(1,:), ...
                                'YData',scene.cameras(1).ScreenY(:,1));
    axis xy;
    colormap(flipud(gray));
    title('Depth map (zBuffer)','FontSize',TITLE_SIZE);
subplot(1,2,2);
    image(Img/255); axis off square;
    title('Image','FontSize',TITLE_SIZE);

