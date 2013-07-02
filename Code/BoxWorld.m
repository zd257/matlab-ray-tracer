function scene = BoxWorld(w, l, h, opt)
% BoxWorld
%   w       - Width of the rectangular box.
%   l       - Length of the rectangular box.
%   h       - Height of the rectangular box.
%   opt     - Optional structure that allows to define the textures for
%             this box world aka the ground, left, right, top, and bottom 
%             plane (in this order) via the fields:
%             * texture which contains the fields:
%               * filepath - Directory for your texture files.
%               * Filename - Names of your texture files.
%               * Scale    - Scaling of your textures.
%               * Ratio    - XY-ratio to adapt your texture to the aspect
%                            ratio of planes.
%               * Id       - Id's for textures in the order of filenames.
%               * IdForObj - Id that is used within the definition of the 
%                            plane objects ground, left, right, top, and
%                            bottom (in this order).
%
% RETURN
%   scene   - Scene object.

%   Florian Raudies, 07/02/2013, Boston University.

if nargin<4,
    opt = struct;
end

if isfield(opt,'texture'),
    texture = opt.texture;
else
    texture.filepath    = '../Textures/';
    texture.Filename    = {'Checkerboard.png', 'DotPattern.png',...
                           'ColorDotPattern.png'};
    texture.Scale       = [3 2 2];
    texture.Ratio       = [1 20/15 20/15];
    texture.Id          = [1 2 3];
    texture.IdForObj    = [1 2 2 3 2]; % ground, left, right, top, bottom
end

if ~isfield(texture,'filepath'), 
    error('Matlab:IO','Field "filepath" in field "texture" required!\n'); 
end
if ~isfield(texture,'Filename'), 
    error('Matlab:IO','Field "Filename" in field "texture" required!\n'); 
end
if ~isfield(texture,'Scale'), 
    error('Matlab:IO','Field "Scale" in field "texture" required!\n'); 
end
if ~isfield(texture,'Ratio'), 
    error('Matlab:IO','Field "Ratio" in field "texture" required!\n'); 
end
if ~isfield(texture,'Id'), 
    error('Matlab:IO','Field "Id" in field "texture" required!\n'); 
end
if ~isfield(texture,'IdForObj'), 
    error('Matlab:IO','Field "IdForObj" in field "texture" required!\n');
end

IdForObj    = texture.IdForObj;
% Create the scene.
scene       = Scene;
GroundPlane = Plane(1,IdForObj(1),...
                    [-w/2; 0; +l/2],[-w/2; 0; -l/2],[+w/2; 0; -l/2]);
LeftWall    = Plane(2,IdForObj(2),...
                    [-w/2; 0; -l/2],[-w/2; 0; +l/2],[-w/2; h; +l/2]);
RightWall   = Plane(3,IdForObj(3),...
                    [+w/2; 0; +l/2],[+w/2; 0; -l/2],[+w/2; h; -l/2]);
TopWall     = Plane(4,IdForObj(4),...
                    [-w/2; 0; +l/2],[+w/2; 0; +l/2],[+w/2; h; +l/2]);
BottomWall  = Plane(5,IdForObj(5),...
                    [+w/2; 0; -l/2],[-w/2; 0; -l/2],[-w/2; h; -l/2]);
% Add primitives.
scene.addObject(GroundPlane);
scene.addObject(LeftWall);
scene.addObject(RightWall);
scene.addObject(TopWall);
scene.addObject(BottomWall);
% Add materials, here 2D textures.
filepath    = texture.filepath;
Filename    = texture.Filename;
Scale       = texture.Scale;
Ratio       = texture.Ratio;
nTxt        = length(Scale);
for iTxt = 1:nTxt,
    scene.addMaterial(...
        Texture2D(1,[filepath,Filename{iTxt}],Scale(iTxt),Ratio(iTxt)));
end
