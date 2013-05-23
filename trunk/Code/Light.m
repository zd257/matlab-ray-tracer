classdef Light
    % The class Light has all properties for a simple point light light
    % source.
    %
    %   Florian Raudies, 05/23/2013, Boston University.
    properties
        id          % Identifier.
        typeName    % Name.
        Pos         % Position in scene.
        Color       % Color for the three channels: red, green, and blue.
        DiffCoef    % Coefficient of diffusity for each color channel.
        SpecCoef    % Specular coefficients for each cholor channel.
        phongExp    % Phong exponent.
    end
    methods
        function obj = Light(id, Pos, Color, DiffCoef, SpecCoef, phongExp)
            obj.id              = id;
            obj.typeName        = 'PointLight';
            obj.Pos             = Pos;
            obj.Color           = Color;
            obj.DiffCoef        = DiffCoef;
            obj.SpecCoef        = SpecCoef;
            obj.phongExp        = phongExp;
        end
    end 
end