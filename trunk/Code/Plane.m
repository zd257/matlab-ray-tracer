classdef Plane < Object
    methods
        % Constructor.
        function obj = Plane(id,materialId,P1,P2,P3)
            % call constructor of superclass
            obj             = obj@Object(id, materialId); 
            obj.typeName    = 'Plane';
            obj.Vertices    = [P1(:) P2(:) P3(:) P1(:)+P3(:)-P2(:)]; % 3 x 4
            obj.U           = [0 0 1 1]; % Texture coordiantes.
            obj.V           = [0 1 1 0];
            obj.TriIndex    = [1 2 3 1 3 4]; % Three indices define a triangle
        end
        % Get vectors that define the triangle, its u, v-vector, normal
        % vector, centroid, and double area.
        function [U V] = getTextureCoordinates(obj)
            U = obj.U(obj.TriIndex); % 6 x 1
            V = obj.V(obj.TriIndex);
            U = reshape(U,[numel(U)/2 2]); % 3 x 2 (three for each triangle)
            V = reshape(V,[numel(V)/2 2]);
        end
        % Get triangles for the plane.
        function Triangles = getTriangles(obj)
            Triangles = obj.Vertices(:,obj.TriIndex); % 3 x 6
            Triangles = reshape(Triangles,...
                [size(Triangles,1)*3 size(Triangles,2)/3]); % 9 x 2
        end
        function [N A2] = getNormalsAreas(obj)
            BmA = obj.Vertices(:,obj.TriIndex(1:3:end)) ...
                - obj.Vertices(:,obj.TriIndex(2:3:end)); ...
            CmA = obj.Vertices(:,obj.TriIndex(3:3:end)) ...
                - obj.Vertices(:,obj.TriIndex(2:3:end)); ...
            N = [BmA(2,:).*CmA(3,:) - BmA(3,:).*CmA(2,:); ...
                 BmA(3,:).*CmA(1,:) - BmA(1,:).*CmA(3,:); ...
                 BmA(1,:).*CmA(2,:) - BmA(2,:).*CmA(1,:)]; % 3 x 2
            A2  = sqrt(N(1,:).^2 + N(2,:).^2 + N(3,:).^2); % 1 x 2
            N   = N./(eps+repmat(A2, [3 1])); % 3 x 2
            A2  = A2/2;
        end
        function C = getCentroids(obj)
            C = 1/3*( obj.Vertices(:,obj.TriIndex(1:3:end)) ...
                    + obj.Vertices(:,obj.TriIndex(2:3:end)) ...
                    + obj.Vertices(:,obj.TriIndex(2:3:end))); % 3 x 2
        end
    end
end