classdef GeometricPrimitive
    % Class GeometricPrimitve is a container class for all geometric
    % primitves that can be described by rectangles.
    properties
        id          % Indentifier (index).
        materialId  % Unique material identifier (index).
        typeName    % Name of this primitive.
        Vertices    % Vertices of triangles.
        TriIndex    % Three vertex indices define a triangle.
        U           % Horizontal texture coordinate.
        V           % Vertical texture coordinate.
    end
    methods
        % Constructor.
        function obj = GeometricPrimitive(id,materialId)
            obj.id          = id;
            obj.materialId  = materialId;
        end
        % Get vectors that define the triangle, its u, v-vector, normal
        % vector, centroid, and double area.
        function [U V] = getVectors(obj)
            U = obj.U(obj.TriIndex); % 3 x 3*nTri
            V = obj.V(obj.TriIndex);
            U = reshape(U,[numel(U)/2 2]);
            V = reshape(V,[numel(V)/2 2]);
            % U, V, and normal, centroid, double area
%             C = 1/3*( obj.Vertices(:,obj.TriIndex(1:3:end)) ...
%                     + obj.Vertices(:,obj.TriIndex(2:3:end)) ...
%                     + obj.Vertices(:,obj.TriIndex(2:3:end))); % 1 x nTri
%             U = [obj.Vertices(:,obj.TriIndex(2:3:end))  ... % 1st vertex
%               -  obj.Vertices(:,obj.TriIndex(1:3:end)); ...
%               ...
%                  obj.Vertices(:,obj.TriIndex(3:3:end))  ... % 2nd vertex
%               -  obj.Vertices(:,obj.TriIndex(2:3:end)); ... 
%               ...
%                  obj.Vertices(:,obj.TriIndex(1:3:end))  ... % 3rd vertex
%               -  obj.Vertices(:,obj.TriIndex(3:3:end))];    
%             V = [obj.Vertices(:,obj.TriIndex(2:3:end))  ... % 1st vertex
%               -  obj.Vertices(:,obj.TriIndex(1:3:end)); ...
%               ...
%               -  obj.Vertices(:,obj.TriIndex(1:3:end))  ... % 2nd vertex
%               -  obj.Vertices(:,obj.TriIndex(3:3:end)); ...
%               ...
%               -  obj.Vertices(:,obj.TriIndex(1:3:end))  ... % 3rd vertex
%               -  obj.Vertices(:,obj.TriIndex(3:3:end))];
%             N = [U(2,:).*V(3,:) - U(3,:).*V(2,:); ...
%                  U(3,:).*V(1,:) - U(1,:).*V(3,:); ...
%                  U(1,:).*V(2,:) - U(2,:).*V(1,:)]; % 3 x nTri
%             % Normalize the normal vector.
%             A2  = sqrt(N(1,:).^2 + N(2,:).^2 + N(3,:).^2); % 1 x nTri
%             N   = N./(eps+repmat(A2, [3 1])); % 3 x nTri
%             U = U./(eps+repmat(sqrt(U(1,:).^2 + U(2,:).^2 + U(3,:).^2),[9 1]));
%             V = V./(eps+repmat(sqrt(V(1,:).^2 + V(2,:).^2 + V(3,:).^2),[9 1]));
        end
        % Get triangles for this object.
        function Triangles = getTriangles(obj)
            Triangles = obj.Vertices(:,obj.TriIndex); % 3 x 3*nTri
            Triangles = reshape(Triangles,[size(Triangles,1)*3 size(Triangles,2)/3]); % 9 x nTri
        end
    end
end
