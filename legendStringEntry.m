classdef legendStringEntry < customStringEntry
    %Class for holding and manipulating legend string entries+
    
    properties (SetAccess = 'immutable')
        leg; % legend
        sidx; % string index
    end
    properties (Dependent)
        String;
        ParentPosition;
        UserData;
    end
    properties (Dependent, SetAccess = 'protected')
        SField;
    end
    
    methods
        function l = legendStringEntry(obj, i)
            if isa(obj, 'matlab.graphics.axis.Axes')
                l.leg = obj.Legend;
            elseif isa(obj, 'matlab.graphics.illustration.Legend')
                l.leg = obj;
            else
                error('Input argument must be legend or axes handle.')
            end
            if nargin < 2
                i = 1;
            end
            l.sidx = i;
            l.origString = l.leg.String{i};
        end
        function s = get.String(l)
            s = l.leg.String{l.sidx};
        end
        function set.String(l, s)
            l.leg.String{l.sidx} = s; 
        end
        function p = get.ParentPosition(l)
            p = l.leg.Position;
        end
        function set.ParentPosition(l, p)
            l.leg.Position = p; 
        end
        function u = get.UserData(l)
            try
                u = l.leg.UserData.legendStringEntryUserData.(l.SField);
            catch
                u = [];
            end
        end
        function set.UserData(l, u)
            l.leg.UserData.legendStringEntryUserData.(l.SField) = u;
        end
        function s = get.SField(l)
            s = ['sidx_', num2str(l.sidx)];
        end
    end
    
    methods (Static)
        function s = getElementName
            s = 'Legend String';
        end
    end
end

