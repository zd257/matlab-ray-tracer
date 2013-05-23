classdef Object
    % Class Object is a container class for all geometric
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
        function obj = Object(id,materialId)
            obj.id          = id;
            obj.materialId  = materialId;
        end
    end
end
