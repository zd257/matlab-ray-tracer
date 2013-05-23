clc
clear all
clear classes
close all

TITLE_SIZE = 18;

% *************************************************************************
% A simple box world to test the ray-tracer. The camera moves on a circular
% track.
%   Florian Raudies, 05/23/2013, Boston University.
% *************************************************************************

% *************************************************************************
% Trajectory for motion.
% *************************************************************************
nStep   = 45; % Number of steps.
r       = 75; % Radius.
Alpha   = 2*pi*linspace(0,1,nStep);
Pos = [+r*cos(Alpha);  repmat(20,[1,nStep]); +r*sin(Alpha);  zeros(1,nStep)];
Dir = [-sin(Alpha);    zeros(1,nStep);       +cos(Alpha);    zeros(1,nStep)];
Up  = [zeros(1,nStep); ones(1,nStep);        zeros(1,nStep); zeros(1,nStep)];
% *************************************************************************
% Dimensions of the box.
% *************************************************************************
w = 200;    % cm width of box
l = 200;    % cm length of box
h = 150;    % cm height of box

% *************************************************************************
% Pinhole Camera
% *************************************************************************
hFov    = 80/180*pi;
vFov    = 80/180*pi;
hPx     = 50;
vPx     = 50;
aaCoef  = 5; % Anti-aliasing with the Fibonacci number of aaCoef samples.

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
scene.addMaterial(Texture2D(1,'../Textures/Checkerboard.png',3));
scene.addMaterial(Texture2D(2,'../Textures/DotPattern.png',2));
scene.addMaterial(Texture2D(3,'../Textures/ColorDotPattern.png',2));
% Add pinhole camera.
scene.addCamera(PinholeCamera(1,[0;0;1;0],[0;1;0;0],[0;20;-80;0],...
                                hFov,vFov,hPx,vPx,aaCoef,[0 10^3]));
% Add light sources.
scene.addLight(Light(1,[80; 100; 0; 0],[50 20 210],[1 0.5 .5],[1 1 1],10^3));
scene.initialize();
% scene.rotateCamera(1,[0 pi/4 0]);

figure;
for iStep = 1:nStep,
    scene.moveCameraTo(1,Pos(:,iStep));
    scene.orientCamera(1,Dir(:,iStep),Up(:,iStep));    
    % *********************************************************************
    % Ray trace to generate the image and depth map (zBuffer).
    % *********************************************************************
    [Img Z] = scene.rayTrace(1); % cameraId is one.
    % *********************************************************************
    % Display the depth map and image.
    % *********************************************************************
    subplot(1,2,1); 
        imshow(log(Z),[0 log(200)], 'XData',scene.cameras(1).ScreenX(1,:), ...
                                    'YData',scene.cameras(1).ScreenY(:,1));
        axis xy;
        colormap(flipud(gray));
        title('Depth map (zBuffer)','FontSize',TITLE_SIZE);
    subplot(1,2,2);
        image(Img/max(Img(:))); axis off square;
        title(sprintf('Image %d x %d pixels',hPx,vPx),'FontSize',TITLE_SIZE);
    drawnow;
end
