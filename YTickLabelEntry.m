classdef YTickLabelEntry < axesStringEntry
    %YTICKLABELENTRY: For manipulation of YTickLabel strings in plotBrowser class
    
    properties
        ax; % reference to axes
    end
    properties (Dependent)
        String;
        UserData;
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
        function u = get.UserData(l)
            try
                u = l.ax.UserData.YTickLabelEntryUserData;
            catch
                u = [];
            end
        end
        function set.UserData(l, u)
            l.ax.UserData.YTickLabelEntryUserData = u;
        end
    end

    methods (Static)
        function s = getElementName
            s = 'YTickLabel';
        end
    end
    
end
