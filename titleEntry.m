classdef titleEntry < axesStringEntry
    %TITLEENTRY: For manipulation of title strings in plotBrowser class
    
    properties
        ax; % reference to axes
    end
    properties (Dependent)
        String;
        UserData;
    end
    
    methods
        function l = titleEntry(obj)
            l.ax = obj;
            l.origString = obj.Title.String;
        end
        function s = get.String(l)
            s = l.ax.Title.String;
        end
        function set.String(l, s)
            l.ax.Title.String = s;
        end
        function u = get.UserData(l)
            try
                u = l.ax.UserData.titleEntryUserData;
            catch
                u = [];
            end
        end
        function set.UserData(l, u)
            l.ax.UserData.titleEntryUserData = u;
        end
    end
    
    methods (Static)
        function s = getElementName
            s = 'Title';
        end
    end
end

