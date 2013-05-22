classdef Material
    properties
        id
        typeName
    end
    methods
        function obj = Material(id, typeName)
            obj.id          = id;
            obj.typeName    = typeName;
        end
    end
end