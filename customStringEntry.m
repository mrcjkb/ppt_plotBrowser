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
            if strcmp(strrep(l.String, char(3), ''), '')
                s = 'off';
            else
                s = 'on';
            end
        end
        function setVisible(l, s)
            if strcmp(s, 'on')
                l.String = l.origString;
            else
                l.origString = l.String;
                str = repmat(char(3), 1, numel(l.origString));
                l.String = str;
            end
        end
    end
    
    methods (Abstract, Static)
        s = getElementName;
    end
end

