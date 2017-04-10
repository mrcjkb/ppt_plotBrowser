function p = plotBrowser(varargin)
    %PLOTBROWSER: GUI tool (similar to Matlab's plotbrowser)
    %intended for quick creation of images for PowerPoint animations.
    %
    %Syntax:
    %
    %   plotBrowser; % opens a plotBrowser for the current figure
    %   plotBrowser(h); % opens a plotBrowser for figure h
    %   p = plotBrowser(_); % returns a plotBrowser object p that contains
    %                       % a cell array of the graphics handles that can
    %                       % be hidden/shown
    %
    %Author: Marc Jakobi
    %        23.03.2017
    %
    %Required functions:
    %
    %   - printfig: For Export feature.
    %   - expandaxes: For Export setup feature.
    %   - spidentify: For Export setup feature.
    %
    %The functions can be downloaded at: https://github.com/MrcJkb/
    %
    %SEE ALSO: plotbrowser
    obj = plotBrowserObj(varargin{:});
    if nargout > 0
        p = obj;
    end
end

