classdef YTickLabelEntry < TickLabelEntry
    %YTICKLABELENTRY: For manipulation of YTickLabel strings in plotBrowser class
    
    properties
        ax; % reference to axes
    end
    properties (Dependent)
        String;
    end
    
    methods
        function l = YTickLabelEntry(obj)
            l.ax = obj;
            l.origString = obj.YTickLabel;
        end
        function s = get.String(l)
            s = l.ax.YTickLabel;
        end
        function set.String(l, s)
            l.ax.YTickLabel = s;
        end
    end

    methods (Static)
        function s = getElementName
            s = 'YTickLabel';
        end
    end
    
end
