classdef Scene < handle
    % The class scene holds all objects, materials, lights, and cameras.
    % It also contains the ray tracer method.
    %
    %   Florian Raudies, 05/22/2013, Boston University.
    properties (Constant = true)
        MAX_TRI_COUNT   = 100   % Maximum number of triangles.
        MAX_VRT_COUNT   = 300   % Maximum number of vertices (3 x traingles)
        MAX_CAM_COUNT   = 10    % Maximum number of cameras.
        MAX_OBJ_COUNT   = 100   % Maximum number of objects.
        MAX_MAT_COUNT   = 50    % Maximum number of materials.
        MAX_LIGHT_COUNT = 10    % Maximum number of lights.
    end
    properties (SetAccess = private)
        Tri         % Matrix with triangles: 9 x nTri
        TriN        % Normal of triangles: 3 x nTri
        TriU        % U coordinate of triangles: 3 x nTri
        TriV        % V coordinate of triangles: 3 x nTri
        TriC        % Centroid of triangles: 3 x nTri
        TriA        % Double area of triangles: 1 x nTri
        TriMatId    % Matrial indices for triangles: 1 x nTri
        nTri        % Number of triangles.
        nObj        % Number of objects.
        nCam        % Number of cameras.
        nLight      % Number of lights.
        nMat        % Number of materials.
    end
    properties 
        objects     % List of objects.
        materials   % List of materials, here used for 2D textures.
        lights      % Light sources, first empty.
        cameras     % Usually only one pinhole camera.
    end
    methods
        % Constructor
        function obj = Scene()
            obj.nTri        = 0;
            obj.nObj        = 0;
            obj.nCam        = 0;
            obj.nLight      = 0;
            obj.nMat        = 0;
            obj.Tri         = NaN([9 Scene.MAX_VRT_COUNT]);
            obj.TriN        = NaN([3 Scene.MAX_TRI_COUNT]);
            obj.TriU        = NaN([3 Scene.MAX_TRI_COUNT]);
            obj.TriV        = NaN([3 Scene.MAX_TRI_COUNT]);
            obj.TriC        = NaN([3 Scene.MAX_TRI_COUNT]);
            obj.TriA        = NaN([1 Scene.MAX_TRI_COUNT]);
            obj.TriMatId    = NaN([1 Scene.MAX_TRI_COUNT]);
            obj.objects     = cell(Scene.MAX_OBJ_COUNT,  1);
            obj.materials   = cell(Scene.MAX_MAT_COUNT,  1);
            obj.lights      = cell(Scene.MAX_LIGHT_COUNT,1);
            obj.cameras     = cell(Scene.MAX_CAM_COUNT,  1);
        end
        function obj = addObject(obj, object) 
            Triangles               = object.getTriangles();
            [U V]                   = object.getTextureCoordinates();
            [N A]                   = object.getNormalsAreas();
            C                       = object.getCentroids();
            Index                   = obj.nTri + (1:size(Triangles,2));
            obj.Tri(:,      Index)  = Triangles;
            obj.TriN(:,     Index)  = N;
            obj.TriU(:,     Index)  = U;
            obj.TriV(:,     Index)  = V;
            obj.TriC(:,     Index)  = C;
            obj.TriA(:,     Index)  = A;
            obj.TriMatId(:, Index)  = object.materialId;
            obj.nTri                = obj.nTri + numel(Index);
            obj.nObj                = obj.nObj + 1;
            obj.objects{obj.nObj}   = object;
        end
        function addMaterial(obj, material)
            obj.nMat                = obj.nMat + 1;
            obj.materials{obj.nMat} = material;
        end
        function addLight(obj, light)
            obj.nLight              = obj.nLight + 1;
            obj.lights{obj.nLight}  = light;
        end
        function addCamera(obj, camera)
            obj.nCam                = obj.nCam + 1;
            obj.cameras{obj.nCam}   = camera;
        end
        function moveCameraTo(obj,cameraId,Pos)
            obj.cameras{cameraId}.moveTo(Pos);
        end
        function moveCameraBy(obj,cameraId,Shift)
            obj.cameras{cameraId}.moveBy(Shift);
        end
        function rotateCamera(obj,cameraId,Rotation)
            obj.cameras{cameraId}.rotate(Rotation); 
        end
        function orientCamera(obj,cameraId,Dir,Up)
            obj.cameras{cameraId}.orient(Dir, Up);
        end
        function initialize(obj)
            obj.Tri         = obj.Tri(:,1:obj.nTri);
            obj.TriN        = obj.TriN(:,1:obj.nTri);
            obj.TriU        = obj.TriU(:,1:obj.nTri);
            obj.TriV        = obj.TriV(:,1:obj.nTri);
            obj.TriC        = obj.TriC(:,1:obj.nTri);
            obj.TriA        = obj.TriA(:,1:obj.nTri);
            obj.TriMatId    = obj.TriMatId(:,1:obj.nTri);
            obj.cameras     = obj.cameras(1:obj.nCam,1);
            obj.lights      = obj.lights(1:obj.nLight,1);
            obj.materials   = obj.materials(1:obj.nMat,1);
            obj.objects     = obj.objects(1:obj.nObj,1);
        end
        function [Img Z Theta Phi] = rayTrace(obj,cameraId)
            camera = obj.cameras{cameraId};
            % Get the position of the camera.
            xE  = camera.Pos(1);
            yE  = camera.Pos(2);
            zE  = camera.Pos(3);
            % Get the image surface with reference to position.
            Dir     = camera.Dir;
            Up      = camera.Up;
            Right   = cross(Dir(1:3), Up(1:3));
            % Range of visiblity.
            t0  = camera.t0;
            t1  = camera.t1;
            nPx = camera.nPx;
            nAa = camera.nAa;
            Z   = zeros(nPx, 1);
            Img = zeros(nPx, 3);
            for iAa = nAa:-1:1, % work on (0,0) last
                % *********************************************************
                % Ray-triangle intersection.
                % *********************************************************
                Xd  = camera.ScreenX(:,iAa);
                Yd  = camera.ScreenY(:,iAa);
                Zd  = camera.ScreenZ(:,iAa);
                X_D = Right(1)*Xd + Right(2)*Yd + Right(3)*Zd;
                Y_D = Up(1)   *Xd + Up(2)   *Yd + Up(3)   *Zd;
                Z_D = Dir(1)  *Xd + Dir(2)  *Yd + Dir(3)  *Zd;
                % Calculate the coefficients for the ray / triangle 
                % intersection, a 3 x 3 equation system.
                A = repmat(obj.Tri(1,:) - obj.Tri(4,:), [nPx 1]); 
                B = repmat(obj.Tri(2,:) - obj.Tri(5,:), [nPx 1]);
                C = repmat(obj.Tri(3,:) - obj.Tri(6,:), [nPx 1]);
                D = repmat(obj.Tri(1,:) - obj.Tri(7,:), [nPx 1]);
                E = repmat(obj.Tri(2,:) - obj.Tri(8,:), [nPx 1]);
                F = repmat(obj.Tri(3,:) - obj.Tri(9,:), [nPx 1]);
                G = repmat(X_D(:),[1 obj.nTri]);
                H = repmat(Y_D(:),[1 obj.nTri]);
                I = repmat(Z_D(:),[1 obj.nTri]);
                J = repmat(obj.Tri(1,:),[nPx 1]) - xE;
                K = repmat(obj.Tri(2,:),[nPx 1]) - yE;
                L = repmat(obj.Tri(3,:),[nPx 1]) - zE;
                % Compute auxiliary variables.
                EI_HF   = E.*I - H.*F;
                GF_DI   = G.*F - D.*I;
                DH_EG   = D.*H - E.*G;
                % Compute determinant
                M       = A.*EI_HF + B.*GF_DI + C.*DH_EG + eps;
                AK_JB   = A.*K - J.*B;
                JC_AL   = J.*C - A.*L;
                BL_KC   = B.*L - K.*C;
                % Compute parmeter that expresses the intersection point 
                % along the ray.
                T       = -(F.*AK_JB + E.*JC_AL + D.*BL_KC)./M;
                Visible = t0<=T & T<=t1;
                % Does the intersection point fall inside the triangle? 
                % 0<gamma<1, 0<beta<1-gamma. 
                % Continue the calculation only with visible points.
                GAMMA           = zeros(nPx, obj.nTri);
                GAMMA(Visible)  = (I(Visible).*AK_JB(Visible) ...
                                +  H(Visible).*JC_AL(Visible) ...
                                +  G(Visible).*BL_KC(Visible))./M(Visible);
                Visible = 0<GAMMA & GAMMA<=1;
                BETA            = zeros(nPx, obj.nTri);
                BETA(Visible)   = (J(Visible).*EI_HF(Visible) ...
                                + K(Visible).*GF_DI(Visible) ...
                                + L(Visible).*DH_EG(Visible))./M(Visible);
                Visible         = 0<BETA & BETA<=(1-GAMMA);
                % Set invisible points to NaN.
                T(~Visible)      = NaN;
                % Determine the closest intersection.
                [Tmin, TriIndex] = min(T,[],2);
                % Compute the depth coordiante for all sample points.
                Z = Z + Tmin.*Zd(:);
                
                % *********************************************************
                % Texture mapping.
                % *********************************************************
                U2D = obj.TriU(:,TriIndex);
                V2D = obj.TriV(:,TriIndex);
                % Select the corresponding paramters BETA and GAMMA.
                SelIndex    = sub2ind([nPx obj.nTri], 1:nPx, TriIndex');
                BETA        = BETA(SelIndex);
                GAMMA       = GAMMA(SelIndex);
                % Compute the coordiantes in texture space.
                U = U2D(1,:) + (U2D(2,:)-U2D(1,:)).*BETA ...
                             + (U2D(3,:)-U2D(1,:)).*GAMMA;
                V = V2D(1,:) + (V2D(2,:)-V2D(1,:)).*BETA ...
                             + (V2D(3,:)-V2D(1,:)).*GAMMA;
                % Work only on pixels that had a hit.
                VisIndex    = find(~isnan(Tmin));
                nVisPx      = length(VisIndex);
                for iVisPx = 1:nVisPx,
                    iPx = VisIndex(iVisPx);
                    % Get the material and its properties for this triangle.
                    material    = obj.materials{obj.TriMatId(TriIndex(iPx))};
                    TextureImg  = material.TextureImg;
                    nX          = material.nX;
                    nY          = material.nY;
                    scale       = material.scale; % scaling of texture
                    ratio       = material.ratio;
                    Img(iPx, :) = Img(iPx, :) ...
                        + reshape(TextureImg( ... % mod wraps circular
                            1 + mod(floor(scale*ratio*V(iPx)*nY), nY), ...
                            1 + mod(floor(scale*U(iPx)*nX), nX), :),[1 3]);
                end
                
                % *********************************************************
                % Compute the contribution from all the light sources.
                % *********************************************************
                % Given light sources we compute their contribution.
                if obj.nLight>0,
                    % Work only on pixels that had a hit.
                    Vx = xE - X_D(VisIndex); % Ray from intersection to camera.
                    Vy = yE - Y_D(VisIndex);
                    Vz = zE - Z_D(VisIndex);
                    % Compute the intersection. for debug plot figure; plot3(Iz,Ix,Iy,'.')
                    Ix = Tmin(VisIndex).*X_D(VisIndex) + xE;
                    Iy = Tmin(VisIndex).*Y_D(VisIndex) + yE;
                    Iz = Tmin(VisIndex).*Z_D(VisIndex) + zE;
                    % Get the normal vectors.
                    Nx = obj.TriN(1,TriIndex(VisIndex))';
                    Ny = obj.TriN(2,TriIndex(VisIndex))';
                    Nz = obj.TriN(3,TriIndex(VisIndex))';
                    % Normalize vectors.
                    LenV = sqrt( Vx.^2 + Vy.^2 + Vz.^2 );
                    Vx = Vx./(eps + LenV);
                    Vy = Vy./(eps + LenV);
                    Vz = Vz./(eps + LenV);
                    for iLight = 1:obj.nLight,
                        light       = obj.lights{iLight};
                        DiffCoef    = light.DiffCoef;
                        SpecCoef    = light.SpecCoef;
                        phongExp    = light.phongExp;
                        Color       = light.Color;
                        DiffColor   = repmat(DiffCoef(:)'.*Color(:)',[nVisPx 1]);
                        SpecColor   = repmat(SpecCoef(:)'.*Color(:)',[nVisPx 1]);
                        Lx = light.Pos(1) - Ix;
                        Ly = light.Pos(2) - Iy;
                        Lz = light.Pos(3) - Iz;
                        % Normalize vector.
                        LenL = sqrt( Lx.^2 + Ly.^2 + Lz.^2 );
                        Lx = Lx./(eps + LenL);
                        Ly = Ly./(eps + LenL);
                        Lz = Lz./(eps + LenL);
                        % Compute h vector.
                        Hx = Vx + Lx;
                        Hy = Vy + Ly;
                        Hz = Vz + Lz;
                        LenH = sqrt( Hx.^2 + Hy.^2 + Hz.^2 );
                        Hx = Hx./(eps + LenH);
                        Hy = Hy./(eps + LenH);
                        Hz = Hz./(eps + LenH);
                        % Compute the inner products.
                        NL = max(0, Nx.*Lx + Ny.*Ly + Nz.*Lz);
                        NH = max(0, Nx.*Hx + Ny.*Hy + Nz.*Hz);
                        NL = repmat(NL,[1 3]);
                        NH = repmat(NH,[1 3]);
                        Img(VisIndex,:) = Img(VisIndex,:)...
                                        + DiffColor.*NL ...
                                        + SpecColor.*NH.^phongExp;
                    end
                end
            end
            % Compute azimuth and elevation of surface normal in camera 
            % coordinates.
            if nargout>2,
                Phi     = NaN(nPx, 1);
                Theta   = NaN(nPx, 1);
                % Get the normal vectors.
                Nx = -obj.TriN(1,TriIndex(VisIndex))';
                Ny = -obj.TriN(2,TriIndex(VisIndex))';
                Nz = -obj.TriN(3,TriIndex(VisIndex))';
                Theta(VisIndex) = atan2(Nx*Right(1)+Ny*Right(2)+Nz*Right(3),...
                                        Nx*Dir(1)+Ny*Dir(2)+Nz*Dir(3));
                Phi(VisIndex)   = atan2(Nx*Up(1)+Ny*Up(2)+Nz*Up(3),...
                                        Nx*Dir(1)+Ny*Dir(2)+Nz*Dir(3));
                Phi     = reshape(Phi,  [camera.vPx camera.hPx]);
                Theta   = reshape(Theta,[camera.vPx camera.hPx]);
            end
            % Reshape to the size of the screen.
            Z   = reshape(Z/nAa,   [camera.vPx camera.hPx]);
            Img = reshape(Img/nAa, [camera.vPx camera.hPx 3]);
        end
    end
end