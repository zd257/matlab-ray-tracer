classdef Camera
    % The class Camera provides a container for different camera models, 
    % e.g. a perspective camera or spherical camera model.
    %
    %   Florian Raudies, 05/22/2013, Boston University.
    properties
        id          % Unique identifier.
        typeName    % Name for the camera.
        Pos         % Position of the camera.
        Dir         % Dir vector of the camera.
        Up          % Up vector of the camera.
        ScreenX     % Screen X, with respect to Pos and Dir, Up.
        ScreenY     % Screen Y.
        ScreenZ     % Screen Z.
        hFov        % Angle for horizontal field of view.
        vFov        % Angle for vertical field of view.
        hPx         % Pixels in horizontal domain.
        vPx         % Pixels in vertical domain.
        t0          % Minimum ray length.
        t1          % Maximum ray length.
    end
    methods
        % Constructor.
        function obj = Camera(id,typeName)
            obj.id          = id;
            obj.typeName    = typeName;
        end
        % Move the camera to the new position Pos.
        function obj = moveTo(obj,Pos)
            obj.Pos     = Pos;
        end
        % Move the camera from its current position by Shift.
        function obj = moveBy(obj,Shift)
            obj.Pos     = obj.Pos + Shift;
        end
        % Rotate the camera.
        function obj = rotate(obj,Rotation)
            M       = rotationMatrix(Rotation);
            obj.Dir = M*obj.Dir;
            obj.Up  = M*obj.Up;
        end
    end
end