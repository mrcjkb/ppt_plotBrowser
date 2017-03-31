classdef (Abstract) customStringEntry < handle
    %CUSTOMSTRINGENTRY: Abstract class for holding and manipulating custom string
    %entries in the plotBrowser class
    
    properties (Dependent)
        Visible;
        origString;
    end
    properties (Abstract, Dependent)
        String;
        ParentPosition;
        UserData;
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
        function o = get.origString(l)
            o = l.UserData.origString;
        end
        function set.origString(l, o)
            if isempty(l.UserData) || ...
                    isempty(l.UserData.origString) || ...
                    all(strcmp(strrep(l.UserData.origString, ' ', ''), '{}')) 
                l.UserData.origString = o;
            end
        end
    end
    
    methods (Access = 'protected')
        function s = getVisible(l)
            if strcmp(strrep(l.String, ' ', ''), '{}')
                s = 'off';
            else
                s = 'on';
            end
        end
        function setVisible(l, s)
            pos = l.ParentPosition;
            if strcmp(s, 'on')
                l.String = l.origString;
            else
                l.origString = l.String;
                str = ['{', repmat(' ', 1, numel(l.origString)), '}'];
                l.String = str;
            end
            l.ParentPosition = pos;
        end
    end
    
    methods (Abstract, Static)
        s = getElementName;
    end
end

