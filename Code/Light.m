classdef Light
    properties
        id
        typeName
        Position
        Direction
        Color
        diffusivity
    end
    methods
        function obj = Light(id,Position,Direction,Color,diffusivity)
            obj.id              = id;
            obj.typeName        = 'PointLight';
            obj.Position        = Position;
            obj.Direction       = Direction;
            obj.Color           = Color;
            obj.diffusivity     = diffusivity;
        end
    end 
end