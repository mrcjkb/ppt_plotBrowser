classdef XLabelEntry < axesStringEntry
    %YLABELENTRY: For manipulation of YLabel strings in plotBrowser class
    
    properties
        ax; % reference to axes
    end
    properties (Dependent)
        String;
    end
    
    methods
        function l = XLabelEntry(obj)
            l.ax = obj;
            l.origString = obj.XLabel.String;
        end
        function s = get.String(l)
            s = l.ax.XLabel.String;
        end
        function set.String(l, s)
            l.ax.XLabel.String = s;
        end
    end
    
    methods (Static)
        function s = getElementName
            s = 'XLabel';
        end
    end
    
end