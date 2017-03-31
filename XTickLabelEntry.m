classdef XTickLabelEntry < TickLabelEntry
    %XTICKLABELENTRY: For manipulation of YTickLabel strings in plotBrowser class
    
    properties
        ax; % reference to axes
    end
    properties (Dependent)
        String;
    end
    
    methods
        function l = XTickLabelEntry(obj)
            l.ax = obj;
            l.origString = obj.XTickLabel;
        end
        function s = get.String(l)
            s = l.ax.XTickLabel;
        end
        function set.String(l, s)
            l.ax.XTickLabel = s;
        end
    end

    methods (Static)
        function s = getElementName
            s = 'XTickLabel';
        end
    end
    
end
