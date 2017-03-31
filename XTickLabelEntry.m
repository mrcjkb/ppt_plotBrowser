classdef XTickLabelEntry < axesStringEntry
    %XTICKLABELENTRY: For manipulation of YTickLabel strings in plotBrowser class
    
    properties
        ax; % reference to axes
    end
    properties (Dependent)
        String;
        UserData;
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
        function u = get.UserData(l)
            try
                u = l.ax.UserData.XTickLabelEntryUserData;
            catch
                u = [];
            end
        end
        function set.UserData(l, u)
            l.ax.UserData.XTickLabelEntryUserData = u;
        end
    end

    methods (Static)
        function s = getElementName
            s = 'XTickLabel';
        end
    end
    
end
