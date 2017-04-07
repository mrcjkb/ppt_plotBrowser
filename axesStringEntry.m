classdef axesStringEntry < customStringEntry
    %AXESSTRINGENTRY Abstract Class for holding and manipulating axes string entries
    
    properties (Dependent)
        ParentPosition;
    end
    
    methods
        function p = get.ParentPosition(l)
            p = l.ax.Position;
        end
        function set.ParentPosition(l, p)
            l.ax.Position = p; 
        end
    end
    
end

