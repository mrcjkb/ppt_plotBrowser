classdef plotBrowser < handle
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
    %SEE ALSO: plotbrowser
    properties
        objList;
    end
    properties (Hidden, Access = 'protected')
        frame; % GUI frame.
        filePath;
        fileName;
        fileExt; % extension.
        counter; % for image number
        hideMode;
        colorButton;
        cObjects;
        states;
        state;
        hndl; % Handle to figure or axes being browsed.
        axes_obj;
        main;
        num  = '01'; % file number as string
        pathname = pwd; % string to file path
        filename = 'img';
        extID = 0;
        colorButtonState_Color;
        colorButtonState_Enabled = false;
        stateIDX = 0;
    end
    properties (Hidden)
        hiddenColor = 'none'; % background color
    end
    properties (Hidden, Constant)
        HTWGREY = [175 175 175]/255;
        PRINTFIGEXT = {'.emf'; '.eps'; '.bmp'; '.jpg'; '.tiff';...
            '.pdf'; '.png'; '.fig'; '.svg'};
    end
    
    methods
        function p = plotBrowser(h)
            if ~usejava('swing') || ~usejava('awt')
                error('java swing and awt packages are missing.')
            end
            if nargin == 0
                h = findobj(0, 'type', 'figure');
                if numel(h) > 1
                    h = gcf;
                end
            end
            if ~isa(h, 'matlab.ui.Figure') && ~isa(h, 'matlab.graphics.axis.Axes')
                error('Input argument h must be a figure or an axes handle')
            elseif isempty(h)
                error('Input argument h points to a deleted graphics object.')
            elseif strcmp(h.Tag, 'plotBrowser')
                % Find figure that is not plotBrowser
                h = findobj(0, 'type', 'figure');
                for i = 1:numel(h)
                    if ~strcmp(h(i).Tag, 'plotBrowser')
                        h = h(i);
                        break
                    end
                end
            end
            p.hndl = h;
            p.axes_obj = findall(h, 'type', 'axes');
            p.frame = figure('WindowStyle', 'normal', 'NumberTitle', 'off', ...
                'CloseRequestFcn', @p.deleteCallback, 'MenuBar', 'none', ...
                'Color', [1 1 1]);
            p.frame.Tag = 'plotBrowser';
            p.refreshUI
            p.frame.ButtonDownFcn = @(src, evt) refreshUI(p, src, evt);
            p.frame.WindowButtonDownFcn	= p.frame.ButtonDownFcn;
            p.states = {plotBrowserColorState(p); plotBrowserVisibleState(p)};
            p.state = p.states{1};
        end
        function deleteCallback(p, src, ~)
            src.CloseRequestFcn = 'closereq';
            close(src)
            delete(p)
        end
    end
    
    methods (Hidden)
        % Callbacks
        function correctFileName(p, src, ~)
            txt = char(src.getText);
            invalids = '[\~!@#$€%^&(){}]]';
            for i = 1:numel(invalids)
                txt = regexprep(txt, invalids(i), '');
            end
            src.setText(txt)
            p.filename = txt;
        end
        function correctNumber(p, src, ~)
            txt = char(src.getText);
            txt = regexprep(txt, '[^\d]', '');
            src.setText(txt);
            p.num = txt;
        end
    end
    
    methods (Access = 'protected')
        function refreshUI(p, ~, ~)
            if ~isvalid(p.hndl)
                warning('Figure has been deleted.')
                close(p.frame)
                return;
            end
            delete(p.main) % force garbage collection to prevent memory leaks
            p.main =  p.uifc(p.frame, 'LR', 'Units', 'norm', 'Position', ...
                [.05, .05, .9, .9]);
            p.initFrameName
            p.initControlUI(p.main)
            p.initListUI(p.main)
        end
        function initFrameName(p)
            h = p.hndl;
            try
                if isempty(h.Name)
                    p.frame.Name = ['plotBrowser: Figure ', num2str(h.Number)];
                else
                    p.frame.Name = ['plotBrowser: ', h.Name];
                end
            catch
                % h = axes object
            end
        end
        function initControlUI(p, component)
            % MTODO: Export button
            import javax.swing.* java.awt.*
            ctrl = p.uifc(component, 'TD');
            cFilename = p.uifc(ctrl, 'LR', 'BackgroundColor', p.HTWGREY);
            cCounter = p.uifc(ctrl, 'LR', 'BackgroundColor', p.HTWGREY);
            cPath = p.uifc(ctrl, 'LR', 'BackgroundColor', p.HTWGREY);
            cHideMode = p.uifc(ctrl, 'TD', 'BackgroundColor', p.HTWGREY);
            p.JLabel(cFilename, 'Name:');
            [p.fileName, ~, ~, h] = p.JTextPane(cFilename, p.filename);
            h.KeyTypedCallback = @(src, evt) correctFileName(p, src, evt);
            [p.fileExt, ~, ~, h] = p.JComboBox(cFilename, p.PRINTFIGEXT);
            p.fileExt.setSelectedIndex(p.extID)
            h.ActionPerformedCallback = @(src, evt) setExtID(p, src, evt);
            p.JLabel(cCounter, 'Number:');
            [p.counter, ~, ~, h] = p.JTextPane(cCounter, p.num);
            h.KeyTypedCallback = @(src, evt) correctNumber(p, src, evt);
            [~, ~, ~, h] = p.JButton(cPath, 'Browse...');
            h.ActionPerformedCallback = @p.browseCallback;
            path = strrep(p.pathname, [fileparts(fileparts(p.pathname)), '\'], '');
            p.filePath = p.JLabel(cPath, path);
            [~, ~, ~, h] = p.JButton(ctrl, 'Export');
            h.ActionPerformedCallback = @p.export;
            [p.colorButton, ~, ~, h] = p.JButton(cHideMode, 'BackgroundColor');
            if isempty(p.colorButtonState_Color)
                p.colorButtonState_Color = Color.WHITE;
            end
            p.colorButton.setForeground(p.colorButtonState_Color)
            p.colorButton.setBackground(p.colorButtonState_Color)
            p.colorButton.setEnabled(p.colorButtonState_Enabled) 
            h.ActionPerformedCallback = @p.chooseColor;
            [j, ~, ~, h] = p.JList(cHideMode, {'Color', 'Custom Color', 'Visible'});
            j.setSelectedIndex(p.stateIDX)
            h.ValueChangedCallback = @p.switchState;
        end
        function initListUI(p, component, varargin)
            import javax.swing.* java.awt.*
            if nargin > 2
                c = p.cObjects.Children;
                for i = 1:numel(c)
                    delete(c(i))
                end
            else
                p.cObjects = p.uifc(component, 'LR');
            end
            cScroll = p.uifc(p.cObjects, 'TD');
            h = p.hndl;
            obj = findobj(h);
            obj = obj(2:end);
            ind = true(size(obj));
            for i = 1:numel(obj)
                if isa(obj(i), 'matlab.graphics.primitive.Text') && isempty(obj(i).String)
                    ind(i) = false;
                end
            end
            obj = obj(ind);
            leg = findobj(h, 'type', 'legend');
            if ~isempty(leg)
                add = numel(leg.String);
            else
                add = 0;
            end
            nEl = numel(obj) + add;
            p.objList = cell(nEl, 1);
            for i = 1:numel(obj)
                p.objList{i} = obj(i);
            end
            % add legend string entries
            ct = 1;
            for i = numel(obj)+1:nEl
                p.objList{i} = legendStringEntry(leg, ct);
                ct = ct + 1;
            end
            % add other custom entries
            nEl = p.addCustomEntries('Title', @titleEntry, nEl);
            nEl = p.addCustomEntries('XLabel', @XLabelEntry, nEl);
            nEl = p.addCustomEntries('YLabel', @YLabelEntry, nEl);
            nEl = p.addCustomEntries('YTickLabel', @YTickLabelEntry, nEl);
            nEl = p.addCustomEntries('XTickLabel', @XTickLabelEntry, nEl);
            ct = 0;
            cct = 1;
            for i = 1:nEl
                obj = p.objList{i};
                if isempty(strfind(p.getElementName(obj), 'Menu'))
                    ct = ct + 1;
                    if ct > nEl / 2 && mod(nEl, 2) == 0 || ...
                            ct > nEl / 3 && nEl > 14 || ...
                            ct > nEl / 5 && nEl > 24 || ...
                            ct > nEl / 7 && nEl > 34 || ...
                            ct > nEl / 9 && nEl > 44
                        ct = 0;
                        cct = cct + 1;
                        cScroll(cct) = p.uifc(component, 'TD');
                    end
                    cObj = p.uifc(cScroll(cct), 'RL', 'BackgroundColor', p.HTWGREY);
                    [~, ~, ~, h] = p.JCheckBox(cObj, p.getElementName(obj));
                    h.ActionPerformedCallback = @(src, evt) p.hideObj(src, evt, obj);
                    if strcmp(p.getElementName(obj), 'Axes')
                        axes(cObj, 'Box', 'on', 'FontSize', 5);
                    else
                        ax = axes(cObj); %#ok<*LAXES>
                        ax.YTick = [];
                        ax.XTick = [];
                        ax.YColor = 'none';
                        ax.XColor = 'none';
                        try
                            cobj = copyobj(obj, ax);
                            % Move copied text so it can be displayed in
                            % plotBrowser
                            if strcmp(p.getElementName(obj), 'Text')
                                cobj.Position(1) = 0;
                                cobj.Position(2) = .5;
                            end
                        catch
                        end
                    end
                end
            end
        end
        function setExtID(p, src, ~)
            p.extID = src.getSelectedIndex;
        end
        function export(p, ~, ~)
            figure(p.hndl)
            p.num = char(p.counter.getText);
            ff = fullfile(p.pathname, [p.filename, p.num]);
            ext = p.PRINTFIGEXT{p.fileExt.getSelectedIndex + 1};
            printfig(p.hndl, ff, ext(2:end))
            figure(p.frame)
            fnum = str2double(p.num) + 1;
            if fnum < 10
                p.num = ['0', num2str(fnum)];
            else
                p.num = num2str(fnum);
            end
            p.counter.setText(p.num)
        end
        function hideObj(p, src, ~, obj)
            if src.isSelected
                p.state.show(obj)
            else
                p.state.hide(obj)
            end
        end
        function browseCallback(p, ~, ~)
            filterSpec = cellfun(@(x) ['*', x], p.PRINTFIGEXT, 'un', false);
            [p.filename, p.pathname, fidx] = uiputfile(filterSpec, 'Save as');
            try
                [~, p.filename, ~] = fileparts(p.filename);
                p.fileName.setText(p.filename)
                path = strrep(p.pathname, [fileparts(fileparts(p.pathname)), '\'], '');
                p.filePath.setText(path)
                p.fileExt.setSelectedIndex(fidx - 1)
                p.correctFileName(p.fileName)
            catch
                % cancelled
            end
        end
        function chooseColor(p, src, ~)
            cc = com.mathworks.mlwidgets.graphics.ColorDialog('Choose the hidden color');
            color = cc.showDialog([]);
            try
                p.hiddenColor = [color.getRed, color.getBlue, color.getGreen] / 255;
                src.setBackground(color)
                src.setForeground(color)
                p.colorButtonState_Color = color;
                p.colorButtonState_Enabled = src.getEnabled;
            catch
                % in case cancel is clicked
            end
        end
        function switchState(p, src, ~)
            p.stateIDX = src.getSelectedIndex;
            if  p.stateIDX == 1 % Custom Color
                p.colorButton.setEnabled(true)
                p.state = p.states{1};
                p.hiddenColor = [1 1 1];
            elseif  p.stateIDX == 2 % Visible
                p.colorButton.setEnabled(false)
                p.state = p.states{2};
            else % Color
                p.colorButton.setEnabled(false)
                p.state = p.states{1};
                p.hiddenColor = 'none';
            end
        end
        function nEl = addCustomEntries(p, type, typeHandle, n0)
            t = findobj(p.hndl, '-property', type);
            ct = 1;
            cct = n0;
            for i = n0:n0+numel(t) - 1
                entry = typeHandle(t(ct));
                if ~isempty(entry.String) && ~all(strcmp(entry.String, '')) && ~all(strcmp(entry.String, char(3)))
                    cct = cct + 1;
                    p.objList{cct} = entry;
                end
                ct = ct + 1;
            end
            nEl = numel(p.objList);
        end
    end
    
    methods (Hidden, Static)
        function u = uifc(parent, flowdirection, varargin)
            if strcmp(flowdirection, 'LR')
                flowdirection = 'LeftToRight';
            elseif strcmp(flowdirection, 'RL')
                flowdirection = 'RightToLeft';
            elseif strcmp(flowdirection, 'TD')
                flowdirection = 'TopDown';
            elseif strcmp(flowdirection, 'BU')
                flowdirection = 'BottomUp';
            end
            u = uiflowcontainer('v0', 'parent', parent, ...
                'FlowDirection', flowdirection, 'BackgroundColor', [1 1 1], ...
                varargin{:});
        end
        function [j, hcomponent, hcontainer] = JLabel(container, str)
            import javax.swing.* java.awt.*
            j = JLabel;
            j.setText(str)
            j.setBackground(Color.white);
            [hcomponent, hcontainer] = javacomponent(j, [], container);
        end
        function [j, hcomponent, hcontainer, h] = JTextPane(container, str)
            import javax.swing.* java.awt.*
            j = JTextPane;
            if nargin > 1
                j.setText(str)
            end
            [hcomponent, hcontainer] = javacomponent(j, [], container);
            if nargout == 4
                h = handle(j, 'CallbackProperties');
            end
        end
        function [j, hcomponent, hcontainer, h] = JCheckBox(container, str)
            import javax.swing.* java.awt.*
            if nargin > 1
                j = JCheckBox(str, true);
            else
                j = JCheckBox(true);
            end
            [hcomponent, hcontainer] = javacomponent(j, [], container);
            if nargout == 4
                h = handle(j, 'CallbackProperties');
            end
        end
        function [j, hcomponent, hcontainer, h] = JComboBox(container, str)
            import javax.swing.* java.awt.*
            j = JComboBox(str);
            [hcomponent, hcontainer] = javacomponent(j, [], container);
            if nargout == 4
                h = handle(j, 'CallbackProperties');
            end
        end
        function [j, hcomponent, hcontainer, h] = JButton(container, str)
            import javax.swing.* java.awt.*
            j = JButton(str);
            [hcomponent, hcontainer] = javacomponent(j, [], container);
            if nargout == 4
                h = handle(j, 'CallbackProperties');
            end
        end
        function [j, hcomponent, hcontainer, h] = JList(container, str)
            import javax.swing.* java.awt.*
            j = JList(str);
            j.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
            [hcomponent, hcontainer] = javacomponent(j, [], container);
            if nargout == 4
                h = handle(j, 'CallbackProperties');
            end
        end
    end
    
    
    methods (Static)
        function s = getElementName(obj)
            if isgraphics(obj)
                type = class(obj);
                ind = strfind(type, '.') + 1;
                s = type(ind(end):end);
            else
                s = obj.getElementName;
            end
        end
    end
end

