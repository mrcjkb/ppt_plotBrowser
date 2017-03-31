classdef plotBrowserVisibleState < plotBrowserState
    %PLOTBROWSERVISIBLESTATE For hiding objects by setting their visibility
    
    properties
    end
    
    methods
        function s = plotBrowserVisibleState(p)
            s@plotBrowserState(p)
        end

        function show(~, obj)
            obj.Visible = 'on';
        end
        
        function hide(~, obj)
            obj.Visible = 'off';
        end
    end
end

