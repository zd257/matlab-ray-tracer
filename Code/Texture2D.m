classdef Texture2D < Material
    properties
        TextureImg  % Image with three color channels.
        fileName    % Filename of texture file.
        nX          % Number of horizontal pixels.
        nY          % Number of vertical pixels.
        scale       % Scaling of the texture.
    end
    methods
        function obj = Texture2D(id, fileName, scale)
            obj             = obj@Material(id, 'texture2D');
            obj.fileName    = fileName;
            obj.TextureImg  = imread(fileName); % assume file exists
            obj.nX          = size(obj.TextureImg,2);
            obj.nY          = size(obj.TextureImg,1);
            obj.scale       = scale;
        end
    end
end