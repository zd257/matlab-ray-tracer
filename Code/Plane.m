classdef Plane < GeometricPrimitive
    methods
        % Constructor.
        function obj = Plane(id,materialId,P1,P2,P3)
            % call constructor of superclass
            obj             = obj@GeometricPrimitive(id, materialId); 
            obj.typeName    = 'Plane';
            obj.Vertices    = [P1(:) P2(:) P3(:) P1(:)+P3(:)-P2(:)]; % 3 x 4
            obj.U           = [0 0 1 1]; % Texture coordiantes.
            obj.V           = [0 1 1 0];
            obj.TriIndex    = [1 2 3 1 3 4]; % Three indices define a triangle
        end
    end
end