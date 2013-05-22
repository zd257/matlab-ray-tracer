classdef PinholeCamera < Camera
    properties
        xMin    % Minimum horizontal coordinate for screen.
        xMax    % Maximum horizontal coordiante for screen.
        yMin    % Minimum vertical coordinate for screen.
        yMax    % Maximum vertical coordinate for screen.
        f       % Focal length.
    end
    methods
        function obj = PinholeCamera(id,Dir,Up,Pos,hFov,vFov,hPx,vPx,Range)
            obj = obj@Camera(id, 'PinholeCamera');
            if hFov/vFov~=hPx/vPx, 
                warning('Matlab:pinholeCamera', ...
                        'Pixels of this obj are non-square!');
            end
            obj.Dir     = Dir/norm(Dir);
            obj.Up      = Up/norm(Dir);
            obj.Pos     = Pos;
            obj.hFov    = hFov;
            obj.vFov    = vFov;
            obj.f       = 0.5/tan(hFov/2);
            obj.hPx     = hPx;
            obj.vPx     = vPx;
            obj.xMin    = -.5;
            obj.xMax    = +.5;
            obj.yMin    = -.5 * vFov/hFov;
            obj.yMax    = +.5 * vFov/hFov;
            [Y X]       = ndgrid(-linspace(obj.yMin, obj.yMax, vPx), ...
                                 +linspace(obj.xMin, obj.xMax, hPx));
            obj.ScreenX = X;
            obj.ScreenY = Y;
            obj.ScreenZ = repmat(obj.f, size(X));
            obj.t0      = Range(1); % Min value.
            obj.t1      = Range(2); % Max value.
        end
    end
end