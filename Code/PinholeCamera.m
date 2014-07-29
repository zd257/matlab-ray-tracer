classdef PinholeCamera < Camera
    properties
        xMin    % Minimum horizontal coordinate for screen.
        xMax    % Maximum horizontal coordiante for screen.
        yMin    % Minimum vertical coordinate for screen.
        yMax    % Maximum vertical coordinate for screen.
        f       % Focal length.
    end
    methods
        function obj = PinholeCamera(...
                id, Dir, Up, Pos, hFov, vFov, hPx, vPx, aaCoef, Range)
            obj = obj@Camera(id, 'PinholeCamera', aaCoef);
            if abs(hFov/vFov-hPx/vPx) > eps,
                warning('Matlab:PinholeCamera', ...
                        'Pixels of this obj are non-square!');
            end
            obj.Dir     = Dir;
            obj.Up      = Up;
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
            obj.t0      = Range(1); % Min value.
            obj.t1      = Range(2); % Max value.
            obj.aaCoef  = aaCoef;
            nPx         = vPx * hPx;
            if aaCoef>2,
                [AaX AaY]   = rank1Lattice(aaCoef);
                nAa         = numel(AaX);
                obj.ScreenX = repmat(X(:),[1 nAa]) ...
                            + repmat(1/hPx*AaX(:)',[nPx 1]);
                obj.ScreenY = repmat(Y(:),[1 nAa]) ...
                            + repmat((vFov/hFov)/vPx*AaY(:)',[nPx 1]);
                obj.ScreenZ = repmat(obj.f, [nPx nAa]);
            else
                nAa         = 1;
                obj.ScreenX = X(:);
                obj.ScreenY = Y(:);
                obj.ScreenZ = repmat(obj.f, [nPx 1]);
            end
            obj.nAa = nAa;
            obj.nPx = nPx;
        end
        function [X Y] = getScreenXY(obj)
            X = reshape(obj.ScreenX(:,1),[obj.vPx obj.hPx]);
            Y = reshape(obj.ScreenY(:,1),[obj.vPx obj.hPx]);
        end
    end
end