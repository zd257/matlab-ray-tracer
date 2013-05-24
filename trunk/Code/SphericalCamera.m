classdef SphericalCamera < Camera
    % The class SphericalCamera implements a spherical camera model with
    % anti-aliasing in spherical coordiantes. I assume that the pixelation
    % is fine and I map the uniform square directly onto each pixel tile in
    % spherical space. Note that a correct random distribution in spherical
    % coordinates for larger intervals is achieved by using a transform.
    % See http://mathworld.wolfram.com/SpherePointPicking.html.
    %
    %   Florian Raudies, 05/24/2013, Boston University.
    methods
        function obj = SphericalCamera(...
                id, Dir, Up, Pos, hFov, vFov, hPx, vPx, aaCoef, Range)
            obj = obj@Camera(id, 'SphericalCamera', aaCoef);
            if hFov/vFov~=hPx/vPx, 
                warning('Matlab:SphericalCamera', ...
                        'Pixels of this obj are non-square!');
            end
            obj.Dir     = Dir;
            obj.Up      = Up;
            obj.Pos     = Pos;
            obj.hFov    = hFov;
            obj.vFov    = vFov;
            [Phi Theta] = ndgrid(-linspace(-vFov/2,+vFov/2,vPx), ...
                                 +linspace(-hFov/2,+hFov/2,hPx));
            obj.t0      = Range(1); % Min value.
            obj.t1      = Range(2); % Max value.
            obj.aaCoef  = aaCoef;
            obj.hPx     = hPx;
            obj.vPx     = vPx;
            nPx         = hPx * vPx;
            if aaCoef>2,
                [PhiDelta ThetaDelta]   = rank1Lattice(aaCoef);
                nAa     = numel(PhiDelta);
                % See http://mathworld.wolfram.com/SpherePointPicking.html.
                % Here I use a simplified version since we are working on
                % a small tile of the space.
                Phi     = repmat(Phi(:),[1 nAa]) ...
                        + repmat(vFov/vPx*PhiDelta(:)',[nPx 1]);
                Theta   = repmat(Theta(:),[1 nAa]) ...
                        + repmat(hFov/hPx*ThetaDelta(:)',[nPx 1]);
            else
                Phi     = Phi(:);
                Theta   = Theta(:);
                nAa     = 1;
            end
            obj.ScreenX = cos(Phi).*sin(Theta);
            obj.ScreenY = sin(Phi);
            obj.ScreenZ = cos(Phi).*cos(Theta);
            obj.nAa     = nAa;
            obj.nPx     = nPx;
        end
    end
end