classdef YLabelEntry < axesStringEntry
    %YLABELENTRY: For manipulation of YLabel strings in plotBrowser class
    
    properties
        ax; % reference to axes
    end
    properties (Dependent)
        String;
        UserData;
    end
    
    methods
        function l = YLabelEntry(obj)
            l.ax = obj;
            l.origString = obj.YLabel.String;
        end
        function s = get.String(l)
            s = l.ax.YLabel.String;
        end
        function set.String(l, s)
            l.ax.YLabel.String = s;
        end
        function u = get.UserData(l)
            try
                u = l.ax.UserData.YLabelEntryUserData;
            catch
                u = [];
            end
        end
        function set.UserData(l, u)
            l.ax.UserData.YLabelEntryUserData = u;
        end
    end
    
    methods (Static)
        function s = getElementName
            s = 'YLabel';
        end
    end
    
end

