clc
clear all
clear classes
close all

TITLE_SIZE = 18;

% *************************************************************************
% A simple box world to test the ray-tracer. The camera moves on a circular
% track.
%   Florian Raudies, 07/02/2013, Boston University.
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
% Construct a box scene from five planes, one texture, and one camera.
% *************************************************************************
scene = BoxWorld(w,l,h);
% Add pinhole camera.
scene.addCamera(PinholeCamera(1,[0;0;1;0],[0;1;0;0],[0;20;-80;0],...
                                80/180*pi,80/180*pi,50,50,5,[0 10^3]));
scene.addCamera(SphericalCamera(1,[0;0;1;0],[0;1;0;0],[0;20;-80;0],...
                                240/180*pi,80/180*pi,75,25,5,[0 10^3]));
% Add light sources.
% scene.addLight(Light(1,[80; 100; 0; 0],[50 20 210],[1 0.5 .5],[1 1 1],10^3));
scene.initialize();
% scene.rotateCamera(1,[0 pi/4 0]);

cameraId = 2;

figure;
for iStep = 1:nStep,
    scene.moveCameraTo(cameraId,Pos(:,iStep));
    scene.orientCamera(cameraId,Dir(:,iStep),Up(:,iStep));
    % *********************************************************************
    % Ray trace to generate the image and depth map (zBuffer).
    % *********************************************************************
    [Img Z] = scene.rayTrace(cameraId); % cameraId is one.
    % *********************************************************************
    % Display the depth map and image.
    % *********************************************************************
    subplot(2,1,1); 
        imshow(Z,[]);
        axis ij;
        colormap(flipud(gray));
        title('Depth map (zBuffer)','FontSize',TITLE_SIZE);
    subplot(2,1,2);
        image(Img/max(Img(:))); axis off equal;
        title('Image','FontSize',TITLE_SIZE);
    drawnow;
end
