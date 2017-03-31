classdef (Abstract) TickLabelEntry < customStringEntry
    %TICKLABELENTRY Abstract class for holding and manipulating custom TickLabel
    %entries in the plotBrowser class. String getters and setters
    %overloaded to work with cell arrays.
    %
    %SEE ALSO: plotBrowser
    
    methods
        function cobj = copyobj(l, ax)
            cobj = text(ax, 0, .5, char(l.origString));
        end
    end
    methods (Access = 'protected')
        function s = getVisible(l)
            if all(cellfun(@(x) ~isempty(strfind(x, char(3))), l.String))
                s = 'off';
            else
                s = 'on';
            end
        end
        function setVisible(l, s)
            if strcmp(s, 'on')
                l.String = l.origString;
            else
                pos = l.ax.Position;
                f = l.ax.Parent;
                c = findobj(f, 'type', 'Colorbar');
                cpos = c.Position;
                l.origString = l.String;
                l.String = cellfun(@(x) repmat(char(3), 1, numel(x)), l.origString, 'un', false);
                l.ax.Position = pos;
                c.Position = cpos;
            end
        end
    end
    
end

