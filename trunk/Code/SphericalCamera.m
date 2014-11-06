classdef SphericalCamera < Camera
    % The class SphericalCamera implements a spherical camera model with
    % anti-aliasing in spherical coordiantes. I assume that the pixelation
    % is fine and I map the uniform square directly onto each pixel tile in
    % spherical space. Note that a correct random distribution in spherical
    % coordinates for larger intervals is achieved by using a transform.
    % See http://mathworld.wolfram.com/SpherePointPicking.html.
    %
    properties
        Theta   % Latitude angle.
        Phi     % Longitude angle.
    end
    %   Florian Raudies, 05/24/2013, Boston University.
    methods
        function obj = SphericalCamera(...
                id, Dir, Up, Pos, hFov, vFov, hPx, vPx, aaCoef, Range)
            obj = obj@Camera(id, 'SphericalCamera', aaCoef);
            if abs(hFov/vFov-hPx/vPx) > eps, 
                warning('Matlab:SphericalCamera', ...
                        'Pixels of this obj are non-square!');
            end
            obj.Dir     = Dir;
            obj.Up      = Up;
            obj.Pos     = Pos;
            obj.hFov    = hFov;
            obj.vFov    = vFov;
            [Ph Th]     = ndgrid(-linspace(-vFov/2,+vFov/2,vPx), ...
                                 +linspace(-hFov/2,+hFov/2,hPx));
            obj.t0      = Range(1); % Min value.
            obj.t1      = Range(2); % Max value.
            obj.aaCoef  = aaCoef;
            obj.hPx     = hPx;
            obj.vPx     = vPx;
            obj.Theta   = Th;
            obj.Phi     = Ph;
            nPx         = hPx * vPx;
            if aaCoef>2,
                [PhDelta ThDelta]   = rank1Lattice(aaCoef);
                nAa     = numel(PhDelta);
                % See http://mathworld.wolfram.com/SpherePointPicking.html.
                % Here I use a simplified version since we are working on
                % a small tile of the space.
                Ph      = repmat(Ph(:),[1 nAa]) ...
                        + repmat(vFov/vPx*PhDelta(:)',[nPx 1]);
                Th      = repmat(Th(:),[1 nAa]) ...
                        + repmat(hFov/hPx*ThDelta(:)',[nPx 1]);
            else
                Ph      = Ph(:);
                Th      = Th(:);
                nAa     = 1;
            end
            obj.ScreenX = cos(Ph).*sin(Th);
            obj.ScreenY = sin(Ph);
            obj.ScreenZ = cos(Ph).*cos(Th);
            obj.nAa     = nAa;
            obj.nPx     = nPx;
        end
        function [Th Ph] = getScreenThetaPhi(obj)
            Th = obj.Theta;
            Ph = obj.Phi;
        end
    end
end