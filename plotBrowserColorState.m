classdef plotBrowserColorState < plotBrowserState
    %PLOTBROWSERCOLORSTATE State class for the plotBrowser. For hiding objects by changing their color.
    %
    %SEE ALSO: plotBrowser
    
    methods
        function s = plotBrowserColorState(p)
            s@plotBrowserState(p)
        end

        function show(s, obj)
            show@plotBrowserState(s, obj)
            obj.Visible = 'on'; % in case it was set to off by other state
            try
                visibleColor = obj.UserData.plotBrowserData.visibleColor;
                visibleMarkerColor = obj.UserData.plotBrowserData.visibleMarkerColor;
                visibleMarkerFaceColor = obj.UserData.plotBrowserData.visibleMarkerFaceColor;
                visibleMarkerEdgeColor = obj.UserData.plotBrowserData.visibleMarkerEdgeColor;
                visibleYColor = obj.UserData.plotBrowserData.visibleYColor;
                visibleXColor = obj.UserData.plotBrowserData.visibleXColor;
            catch
                visibleColor = [];
                visibleMarkerColor = [];
                visibleMarkerFaceColor = [];
                visibleMarkerEdgeColor = [];
                visibleYColor = [];
                visibleXColor = [];
            end
            if ~isempty(visibleColor)
                obj.Color = visibleColor;
            end
            if ~isempty(visibleMarkerColor)
                obj.MarkerColor = visibleMarkerColor;
            end
            if ~isempty(visibleMarkerFaceColor)
                obj.MarkerFaceColor = visibleMarkerFaceColor;
            end
            if ~isempty(visibleMarkerEdgeColor)
                obj.MarkerEdgeColor = visibleMarkerEdgeColor;
            end
            if ~isempty(visibleYColor)
                obj.YColor = visibleYColor;
            end
            if ~isempty(visibleXColor)
                obj.XColor = visibleXColor;
            end
        end
        function hide(s, obj)
            hide@plotBrowserState(s, obj)
            backgroundColor = s.plotBrowserObj.hiddenColor;
            try
                visibleMarkerColor = obj.MarkerColor;
                obj.MarkerColor = backgroundColor;
            catch
                visibleMarkerColor = [];
            end
            try
                visibleMarkerFaceColor = obj.MarkerFaceColor;
                visibleMarkerEdgeColor = obj.MarkerEdgeColor;
                obj.MarkerFaceColor = backgroundColor;
                obj.MarkerEdgeColor = backgroundColor;
            catch
                visibleMarkerFaceColor = [];
                visibleMarkerEdgeColor = [];
            end
            try
                visibleYColor = obj.YColor;
                visibleXColor = obj.XColor;
                obj.YColor = backgroundColor;
                obj.XColor = backgroundColor;
            catch
                visibleYColor = [];
                visibleXColor = [];
            end
            try
                visibleColor = obj.Color;
                obj.Color = backgroundColor;
            catch
                visibleColor = [];
            end
            obj.UserData.plotBrowserData.visibleMarkerColor = visibleMarkerColor;
            obj.UserData.plotBrowserData.visibleMarkerFaceColor = visibleMarkerFaceColor;
            obj.UserData.plotBrowserData.visibleMarkerEdgeColor = visibleMarkerEdgeColor;
            obj.UserData.plotBrowserData.visibleYColor = visibleYColor;
            obj.UserData.plotBrowserData.visibleXColor = visibleXColor;
            obj.UserData.plotBrowserData.visibleColor = visibleColor;
        end
    end
end

