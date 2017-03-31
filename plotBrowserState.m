classdef (Abstract) plotBrowserState < handle
    %PLOTBROWSERSTATE Abstract State interface for the plotBrowser.
    %
    %SEE ALSO: plotBrowser
    
    properties
        plotBrowserObj;
    end
    
    methods
        function s = plotBrowserState(obj)
            s.plotBrowserObj = obj;
        end
        function hide(s, obj)
            if s.isLegendColorbarOrCustomElement(obj)
                obj.Visible = 'off';
            end
        end
        function show(s, obj)
            if s.isLegendColorbarOrCustomElement(obj)
                obj.Visible = 'on';
            end
        end
    end
    
    methods (Static)
        function tf = isLegendColorbarOrCustomElement(obj)
            tf = strcmp(plotBrowser.getElementName(obj), 'Legend') || ...
            strcmp(plotBrowser.getElementName(obj), 'Legend String') || ...
            strcmp(plotBrowser.getElementName(obj), 'Title') || ...
            strcmp(plotBrowser.getElementName(obj), 'XLabel') || ...
            strcmp(plotBrowser.getElementName(obj), 'YLabel') || ...
            strcmp(plotBrowser.getElementName(obj), 'YTickLabel') || ...
            strcmp(plotBrowser.getElementName(obj), 'XTickLabel') || ...
            strcmp(plotBrowser.getElementName(obj), 'ColorBar');
        end
    end

end

