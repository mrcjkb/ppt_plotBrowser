classdef (Abstract) customStringEntry < handle
    %CUSTOMSTRINGENTRY: Abstract class for holding and manipulating custom string
    %entries in the plotBrowser class
    
    properties
       UserData; 
    end
    properties (Dependent)
        Visible;
    end
    properties (Abstract, Dependent)
        String;
        ParentPosition;
    end
    properties (Hidden, Access = 'protected')
        origString = '';
    end
    
    methods
        function cobj = copyobj(l, ax)
            cobj = text(ax, 0, .5, l.origString);
        end
        function s = get.Visible(l)
            s = l.getVisible;
        end
        function set.Visible(l, s)
            l.setVisible(s)
        end
    end
    
    methods (Access = 'protected')
        function s = getVisible(l)
            if isempty(l.String)
                s = 'off';
            else
                s = 'on';
            end
        end
        function setVisible(l, s)
            if strcmp(s, 'on')
                l.String = l.origString;
            else
                pos = l.ParentPosition;
                l.origString = l.String;
                l.String = '';
                l.ParentPosition = pos;
            end
        end
    end
    
    methods (Abstract, Static)
        s = getElementName;
    end
end

