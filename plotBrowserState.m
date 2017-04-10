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
            tf = strcmp(plotBrowserObj.getElementName(obj), 'Legend') || ...
            strcmp(plotBrowserObj.getElementName(obj), 'Legend String') || ...
            strcmp(plotBrowserObj.getElementName(obj), 'Title') || ...
            strcmp(plotBrowserObj.getElementName(obj), 'XLabel') || ...
            strcmp(plotBrowserObj.getElementName(obj), 'YLabel') || ...
            strcmp(plotBrowserObj.getElementName(obj), 'YTickLabel') || ...
            strcmp(plotBrowserObj.getElementName(obj), 'XTickLabel') || ...
            strcmp(plotBrowserObj.getElementName(obj), 'ColorBar');
        end
    end

end

