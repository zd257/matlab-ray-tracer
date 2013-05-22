classdef Scene
    % The class scene holds all primitives, materials, lights, and cameras.
    % It also contains the ray tracer method.
    %
    %   Florian Raudies, 05/22/2013, Boston University.
    properties (Constant = true)
        MAX_TRI_COUNT = 100 % Maximum number of triangles.
        MAX_VRT_COUNT = 300
    end
    properties (SetAccess = private)
        Tri         % Matrix with triangles: 9 x nTri
        TriN        % Normal of triangles: 3 x nTri
        TriU        % U coordinate of triangles: 3 x nTri
        TriV        % V coordinate of triangles: 3 x nTri
        TriC        % Centroid of triangles: 3 x nTri
        TriA2       % Double area of triangles: 1 x nTri
        TriMatId    % Matrial indices for triangles: 1 x nTri
        nTri        % Number of triangles.
    end
    properties 
        primitives  % List of primitives.
        materials   % List of materials, here used for 2D textures.
        lights      % Light sources, first empty.
        cameras     % Usually only one pinhole camera.
    end
    methods
        % Constructor
        function obj = Scene()
            obj.nTri        = 0;
            obj.Tri         = NaN([9 Scene.MAX_VRT_COUNT]);
%             obj.TriN        = NaN([3 Scene.MAX_TRI_COUNT]);
            obj.TriU        = NaN([3 Scene.MAX_TRI_COUNT]);
            obj.TriV        = NaN([3 Scene.MAX_TRI_COUNT]);
%             obj.TriC        = NaN([3 Scene.MAX_TRI_COUNT]);
%             obj.TriA2       = NaN([1 Scene.MAX_TRI_COUNT]);
            obj.TriMatId    = NaN([1 Scene.MAX_TRI_COUNT]);
            obj.primitives  = []; % initialize as empty list
            obj.materials   = [];
            obj.lights      = [];
            obj.cameras     = [];
        end
        function obj = addPrimitive(obj, primitive) 
            Triangles               = primitive.getTriangles();
            [U V]                   = primitive.getVectors();
            Index                   = obj.nTri + (1:size(Triangles,2));
            obj.Tri(:,      Index)  = Triangles;
%             obj.TriN(:,     Index)  = N;
            obj.TriU(:,     Index)  = U;
            obj.TriV(:,     Index)  = V;
%             obj.TriC(:,     Index)  = C;
%             obj.TriA2(:,    Index)  = A2;
            obj.TriMatId(:, Index)  = primitive.materialId;
            obj.nTri                = obj.nTri + numel(Index);
            obj.primitives          = [obj.primitives primitive];
        end
        function obj = addMaterial(obj, material)
            obj.materials = [obj.materials material];
        end
        function obj = addLight(obj, light)
            obj.lights = [obj.lights light];
        end
        function obj = addCamera(obj, camera)
            obj.cameras = [obj.cameras camera];
        end
        function obj = moveToCamera(obj,cameraId,Pos)
            obj.cameras(cameraId) = obj.cameras(cameraId).moveTo(Pos);
        end
        function obj = moveByCamera(obj,cameraId,Shift)
            obj.cameras(cameraId) = obj.cameras(cameraId).moveBy(Shift);
        end
        function obj = rotateCamera(obj,cameraId,Rotation)
            obj.cameras(cameraId) = obj.cameras(cameraId).rotate(Rotation); 
        end
        function obj = initialize(obj)
            obj.Tri   = obj.Tri(:,1:obj.nTri);
%             obj.TriN  = obj.TriN(:,1:obj.nTri);
            obj.TriU  = obj.TriU(:,1:obj.nTri);
            obj.TriV  = obj.TriV(:,1:obj.nTri);
%             obj.TriC  = obj.TriC(:,1:obj.nTri);
%             obj.TriA2 = obj.TriA2(:,1:obj.nTri);
            obj.TriMatId = obj.TriMatId(:,1:obj.nTri);            
        end
        function [Img Z] = rayTrace(obj,cameraId)
            camera = obj.cameras(cameraId);
            % Get the position of the camera.
            xE  = camera.Pos(1);
            yE  = camera.Pos(2);
            zE  = camera.Pos(3);
            % Get the image surface with reference to position.
            Xd  = camera.ScreenX;
            Yd  = camera.ScreenY;
            Zd  = camera.ScreenZ;
            Dir = camera.Dir;
            Up  = camera.Up;
            Right   = cross(Dir(1:3), Up(1:3));
            X_D     = Right(1)*Xd + Right(2)*Yd + Right(3)*Zd;
            Y_D     = Up(1)   *Xd + Up(2)   *Yd + Up(3)   *Zd;
            Z_D     = Dir(1)  *Xd + Dir(2)  *Yd + Dir(3)  *Zd;
            % Range of visiblity.
            t0  = camera.t0;
            t1  = camera.t1;
            nPx = numel(Xd);
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
            % Compute parmeter that expresses the intersection point along the ray.
            T       = -(F.*AK_JB + E.*JC_AL + D.*BL_KC)./M;
            Visible = t0<=T & T<=t1;
            % Does the intersection point fall inside the triangle? 
            % 0<gamma<1, 0<beta<1-gamma. 
            % For efficiency, continue the calculation only with visible points.
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
            % Set NaN for invisible points.
            T(~Visible)      = NaN;
            % Determine the closest intersection.
            [Tmin, TriIndex] = min(T,[],2);
            % Compute the depth coordiante for all sample points.
            Z = Tmin.*Zd(:); 
            % Reshape to the size of the screen.
            Z = reshape(Z,size(Xd));
            % *************************************************************
            % Texture mapping.
            % *************************************************************
            U2D = obj.TriU(:,TriIndex);
            V2D = obj.TriV(:,TriIndex);
            % Select the corresponding paramters BETA and GAMMA.
            Index   = sub2ind([nPx obj.nTri], 1:nPx, TriIndex');
            BETA    = BETA(Index);
            GAMMA   = GAMMA(Index);
            % Compute the coordiantes in texture space.
            U = U2D(1,:) + (U2D(2,:)-U2D(1,:)).*BETA ...
                         + (U2D(3,:)-U2D(1,:)).*GAMMA;
            V = V2D(1,:) + (V2D(2,:)-V2D(1,:)).*BETA ...
                         + (V2D(3,:)-V2D(1,:)).*GAMMA;
            % Image with zeros.
            Img = zeros(nPx, 3);
            for iPx = 1:nPx,
                % Get the material and its properties for this triangle.
                material    = obj.materials(obj.TriMatId(TriIndex(iPx)));
                TextureImg  = material.TextureImg;
                nX          = material.nX;
                nY          = material.nY;
                scale       = material.scale;
                Img(iPx, :) = TextureImg( 1+mod(floor(scale*V(iPx)*nY),nY), ...
                                          1+mod(floor(scale*U(iPx)*nX),nX), :);
            end
            % Reshape to the size of the screen.
            Img = reshape(Img,[size(Xd) 3]);
        end
    end
end