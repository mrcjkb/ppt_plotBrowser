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
    
    methods (Access = 'protected')
        function setVisible(l, s)
            pos = l.getLabelPositions;
            setVisible@customStringEntry(l, s)
            l.setLabelPositions(pos)
        end
        function pos = getLabelPositions(l)
            pos.Y = l.ax.YLabel.Position;
            pos.X = l.ax.XLabel.Position;
            pos.T = l.ax.Title.Position;
        end
        function setLabelPositions(l, pos)
            l.ax.YLabel.Position = pos.Y;
            l.ax.XLabel.Position = pos.X;
            l.ax.Title.Position = pos.T;
        end
    end
    
end

