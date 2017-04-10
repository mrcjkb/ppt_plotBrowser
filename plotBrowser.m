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
    %Required functions:
    %
    %   - printfig: For Export feature. Available at: https://github.com/MrcJkb/printfig.git
    %   - expandaxes: For Export setup feature.
    %   - spidentify: For Export setup feature.
    %
    %SEE ALSO: plotbrowser
    
    properties
        %Cell array of the graphics objects
        %(and plotBrowser customStringEntry subclasses) that can be
        %hidden/shown by the plotBrowser GUI.
        objList;
        hndl; % Handle to figure or axes being browsed.
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
        axes_obj;
        main;
        num  = '01'; % file number as string
        pathname = pwd; % string to file path
        filename = 'img';
        extID = 0;
        colorButtonState_Color;
        colorButtonState_Enabled = false;
        stateIDX = 0;
        tabgp; % uitabgroup
    end
    properties (Hidden)
        hiddenColor = 'none'; % background color
    end
    properties (Hidden, Constant)
        HTWGREY = [175 175 175]/255; % Used as backround color for GUI
        PRINTFIGEXT = {'.emf'; '.eps'; '.bmp'; '.jpg'; '.tiff';...
            '.pdf'; '.png'; '.fig'; '.svg'}; % Printfig 
    end
    
    methods
        function p = plotBrowser(h)
            if verLessThan('matlab', '9.0') % Verify Matlab version (R2016a and above)
                error('Matlab R2016a or above required to run this tool.')
            end
            if ~usejava('swing') || ~usejava('awt') % Check if required java packages are installed
                error('java swing and awt packages are missing.')
            end
            if nargin == 0 % Apply to current figure if none specified
                h = findobj(0, 'type', 'figure');
                if numel(h) > 1
                    h = gcf;
                elseif isempty(h)
                    error('No figure found.')
                end
            end
            if ~isa(h, 'matlab.ui.Figure') % Check for correct input
                error('Input argument h must be a figure handle')
            elseif isempty(h)
                error('Input argument h points to a deleted graphics object.')
            elseif strcmp(h.Tag, 'plotBrowser')
                % Find figure that is not a plotBrowser GUI frame
                h = findobj(0, 'type', 'figure');
                for i = 1:numel(h)
                    if ~strcmp(h(i).Tag, 'plotBrowser')
                        h = h(i);
                        break
                    end
                end
            end
            h.CloseRequestFcn = @p.deleteCallback;
            p.hndl = h;
            p.axes_obj = findall(h, 'type', 'axes');
            % Initialize GUI
            p.frame = figure('WindowStyle', 'normal', 'NumberTitle', 'off', ...
                'CloseRequestFcn', @p.deleteCallback, 'MenuBar', 'none', ...
                'Color', [1 1 1]);
            p.frame.Tag = 'plotBrowser';
            p.refreshUI
            % Set ButtonDownFcn to refresh UI so that changes to the figure
            % are applied.
            p.frame.ButtonDownFcn = @(src, evt) refreshUI(p, src, evt);
            p.frame.WindowButtonDownFcn	= p.frame.ButtonDownFcn;
            p.states = {plotBrowserColorState(p); plotBrowserVisibleState(p)};
            p.state = p.states{1}; % Initialize state
        end
        function deleteCallback(p, src, ~)
            % Reset closereq function, close figure and delete plotBrowser
            % object
            p.hndl.CloseRequestFcn = 'closereq';
            p.frame.CloseRequestFcn = 'closereq';
            close(src)
            try close(p.frame); catch; end
            delete(p)
        end
    end
    
    methods (Hidden)
        % Callbacks
        function correctFileName(p, src, ~)
            % Remove invalid characters from file name input
            txt = char(src.getText);
            invalids = '[\~!@#$€%^&(){}]]';
            for i = 1:numel(invalids)
                txt = regexprep(txt, invalids(i), '');
            end
            src.setText(txt)
            p.filename = txt;
        end
        function correctNumber(~, src, ~)
            % Remove invalid characters from counter input
            txt = char(src.getText);
            txt = regexprep(txt, '[^\d]', '');
            src.setText(txt);
        end
    end
    
    methods (Access = 'protected')
        function refreshUI(p, ~, ~)
            if ~isvalid(p.hndl) % Make sure handle is still valid and close GUI if not
                warning('Figure has been deleted.')
                close(p.frame)
                return;
            end
            if nargin > 1
                selectedTab = str2double(p.tabgp.SelectedTab.Tag);
            else
                selectedTab = 1;
            end
            delete(p.main) % force garbage collection to prevent memory leaks
            p.main =  p.uifc(p.frame, 'LR', 'Units', 'norm', 'Position', ...
                [.05, .05, .9, .9]);
            p.initFrameName
            p.initControlUI(p.main)
            p.tabgp = uitabgroup(p.main);
            plist = uitab(p.tabgp, 'Title', 'plot browser', 'Tag', '1');
            pctrl2 = uitab(p.tabgp, 'Title', 'export setup', 'Tag', '2');
            if selectedTab == 1
                p.tabgp.SelectedTab = plist;
                plist_uifc = p.uifc(plist, 'LR'); % Wrap uitab in uiflowcontainer
                p.initListUI(plist_uifc) % Initialize UI elements
            else
                p.tabgp.SelectedTab = pctrl2;
                pctrl2_uifc = p.uifc(pctrl2, 'TD');
                p.initCtrl2UI(pctrl2_uifc)
            end
        end
        function initFrameName(p)
            % Initializes the GUI frame's title bar.
            h = p.hndl;
            if isempty(h.Name) % Figure has no name --> init with figure number
                p.frame.Name = ['plotBrowser: Figure ', num2str(h.Number)];
            else
                p.frame.Name = ['plotBrowser: ', h.Name];
            end
        end
        function initControlUI(p, component)
            % Initializes the GUI for exporting the images and setting the
            % state
            import javax.swing.* java.awt.*
            ctrl = p.uifc(component, 'TD'); % uiflowcontainer for controls
            % uiflowcontainers for control pairs
            cFilename = p.uifc(ctrl, 'LR', 'BackgroundColor', p.HTWGREY);
            cCounter = p.uifc(ctrl, 'LR', 'BackgroundColor', p.HTWGREY);
            cPath = p.uifc(ctrl, 'LR', 'BackgroundColor', p.HTWGREY);
            cHideMode = p.uifc(ctrl, 'TD', 'BackgroundColor', p.HTWGREY);
            % File name
            p.JLabel(cFilename, 'Name:');
            [p.fileName, ~, ~, h] = p.JTextPane(cFilename, p.filename);
            h.KeyTypedCallback = @(src, evt) correctFileName(p, src, evt);
            % File Extension selector
            [p.fileExt, ~, ~, h] = p.JComboBox(cFilename, p.PRINTFIGEXT);
            p.fileExt.setSelectedIndex(p.extID)
            h.ActionPerformedCallback = @(src, evt) setExtID(p, src, evt);
            % Export counter
            p.JLabel(cCounter, 'Number:');
            [p.counter, ~, ~, h] = p.JTextPane(cCounter, p.num);
            h.KeyTypedCallback = @(src, evt) setFileNum(p, src, evt);
            % File chooser for save location
            [~, ~, ~, h] = p.JButton(cPath, 'Browse...');
            h.ActionPerformedCallback = @p.browseCallback;
            path = strrep(p.pathname, [fileparts(fileparts(p.pathname)), '\'], '');
            p.filePath = p.JLabel(cPath, path);
            % Export button
            [~, ~, ~, h] = p.JButton(ctrl, 'Export');
            h.ActionPerformedCallback = @p.export;
            % Color chooser (only enabled for custom color state)
            [p.colorButton, ~, ~, h] = p.JButton(cHideMode, 'BackgroundColor');
            if isempty(p.colorButtonState_Color)
                p.colorButtonState_Color = Color.WHITE;
            end
            p.colorButton.setForeground(p.colorButtonState_Color)
            p.colorButton.setBackground(p.colorButtonState_Color)
            p.colorButton.setEnabled(p.colorButtonState_Enabled) 
            h.ActionPerformedCallback = @p.chooseColor;
            % State selector
            [j, ~, ~, h] = p.JScrollList(cHideMode, {'Color: ''none''', 'Custom Color', 'Visible'});
            j.setSelectedIndex(p.stateIDX)
            h.ValueChangedCallback = @p.switchState;
        end
        function initListUI(p, component, varargin)
            % Intitializes the list of graphics objects to be shown/hidden
            import javax.swing.* java.awt.*
            if nargin > 2 % Delete graphics object visualizations from GUI if called as callback
                c = p.cObjects.Children;
                for i = 1:numel(c)
                    delete(c(i))
                end
            else % First initialization
                p.cObjects = p.uifc(component, 'LR'); % Main uiflowcontainer
            end
            cScroll = p.uifc(p.cObjects, 'TD'); % Array of sub-containers
            h = p.hndl;
            obj = findobj(h); % all graphics objects
            obj = obj(2:end); % Remove figure & menu objects
            % Remove empty text elements from list
            ind = true(size(obj));
            for i = 1:numel(obj)
                if isa(obj(i), 'matlab.graphics.primitive.Text') && isempty(obj(i).String)
                    ind(i) = false;
                end
            end
            obj = obj(ind);
            % Add legend strings via legendStringEntry Adapter classes
            leg = findobj(h, 'type', 'legend');
            if ~isempty(leg)
                add = numel(leg.String);
            else
                add = 0;
            end
            nEl = numel(obj) + add; % Number of elements
            p.objList = cell(nEl, 1); % Init object list property
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
            % Loop through object list and create check marks and
            % vizualizations
            ct = 0;
            cct = 1;
            for i = 1:nEl
                obj = p.objList{i};
                try
                    hidden = obj.UserData.hidden;
                catch
                    hidden = false;
                    obj.UserData.hidden = hidden;
                end
                if isempty(strfind(p.getElementName(obj), 'Menu')) %#ok<STREMP> % Leave out menu items
                    % Extend horizontally as needed for cleaner GUI look
                    % (Scrollbars cannot hold Matlab axes objects)
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
                    % Create checkbox-visualization pairs in
                    % uiflowcontainers
                    cObj = p.uifc(cScroll(cct), 'RL', 'BackgroundColor', p.HTWGREY);
                    [j, ~, ~, h] = p.JCheckBox(cObj, p.getElementName(obj));
                    if hidden
                        j.setSelected(false)
                    end
                    h.ActionPerformedCallback = @(src, evt) p.hideObj(src, evt, obj);
                    if strcmp(p.getElementName(obj), 'Axes')
                        % Create blank axes for axes objects
                        axes(cObj, 'Box', 'on', 'FontSize', 5, 'Color', [1 1 1]);
                    else
                        % Copy other objects for vizualization
                        ax = axes(cObj); %#ok<*LAXES>
                        ax.YTick = [];
                        ax.XTick = [];
                        ax.YColor = 'none';
                        ax.XColor = 'none';
                        ax.Color = [1 1 1];
                        try
                            cobj = copyobj(obj, ax);
                            % Move copied text so it can be displayed in
                            % plotBrowser
                            if strcmp(p.getElementName(obj), 'Text')
                                cobj.Position(1) = 0;
                                cobj.Position(2) = .5;
                            end
                        catch ME
                            sc = superclasses(obj);
                            if strcmp(sc{end-1}, 'customStringEntry')
                                rethrow(ME)
                            end
                        end
                    end
                end
            end
        end
        function initCtrl2UI(p, component, varargin)
            % MTODO: Write function for initializing additional tools
            p.initExpandaxesUI(component, varargin)
        end
        function initExpandaxesUI(p, component, varargin)
            % MTODO: Copy new expandaxes update to server
            cObj = p.uifc(component, 'LR', 'BackgroundColor', p.HTWGREY);
            [~, ~, ~, hCheckBox] = p.JCheckBox(cObj, 'expandaxes');
            try
                fhor = p.hndl.UserData.plotBrowserData.fhor; 
            catch
                fhor = 1;
                p.hndl.UserData.plotBrowserData.fhor = fhor;
            end
            try 
                fver = p.hndl.UserData.plotBrowserData.fver; 
            catch
                fver = 1;
                p.hndl.UserData.plotBrowserData.fver = fver;
            end
            AX = findobj(p.hndl, 'type', 'axes');
            if ~strcmp(AX(1).Tag, 'expandedaxes')
                hCheckBox.setSelected(false)
            end
            hCheckBox.ActionPerformedCallback = @(src, evt) p.expandaxes(src);
            fHor = p.uifc(cObj, 'TD', 'BackgroundColor', p.HTWGREY);
            fVer = p.uifc(cObj, 'TD', 'BackgroundColor', p.HTWGREY);
            fhorL = p.JLabel(fHor, 'fHor:');
            fverL = p.JLabel(fVer, 'fVer:');
            % fhor and fver presets are stored in figure's UserData
            [~, ~, nHor, nVer] = spidentify(p.hndl); % MTODO: Move spidentify to GitHub    
            [fh, ~, ~, h] = p.JTextPane(fHor, num2str(fhor));
            if nHor == 1 % Disable params if only 1 axes in horizontal direction
                fhorL.setEnabled(false)
                fh.setEnabled(false)
            end
            h.KeyTypedCallback = @(src, evt) setFHor(p, src, evt);
            [fv, ~, ~, h] = p.JTextPane(fVer, num2str(fver));
            if nVer == 1 % Disable params if only 1 axes in vertical direction
                fverL.setEnabled(false)
                fv.setEnabled(false)
            end
            h.KeyTypedCallback = @(src, evt) setFVer(p, src, evt);
        end
        function expandaxes(p, src)
            % Wrapper for the expandaxes function
            fhor = p.hndl.UserData.plotBrowserData.fhor;
            fver = p.hndl.UserData.plotBrowserData.fver;
            undo = ~src.isSelected;
            figure(p.hndl) % Switch to referenced figure from plotBrowser GUI
            expandaxes(p.hndl, fhor, fver, 'Undo', undo)
            figure(p.frame) % Switch back to plotBrowser
        end
        function setFHor(p, src, evt)
            % Stores fhor preset in figure's UserData
            p.correctNumber(src, evt)
            p.hndl.UserData.plotBrowserData.fhor = str2double(char(src.getText));
        end
        function setFVer(p, src, evt)
            % Stores fver preset in figure's UserData
            p.correctNumber(src, evt)
            p.hndl.UserData.plotBrowserData.fver = str2double(char(src.getText));
        end
        function setFileNum(p, src, evt)
            p.correctNumber(src, evt)
            p.num = char(src.getText);
        end
        function setExtID(p, src, ~)
            % Stores selected extension index for UI refreshes
            p.extID = src.getSelectedIndex;
        end
        function export(p, ~, ~)
            % Exports figure to image file
            if isempty(which('printfig'))
                waitfor(msgbox(['The printfig function is required for exporting. ', ...
                    'It can be downloaded from: https://github.com/MrcJkb/printfig.git'], 'Error', 'ERROR'))
                return;
            end
            figure(p.hndl) % Switch to referenced figure from plotBrowser GUI
            % Retrieve required info from UI
            p.num = char(p.counter.getText);
            ff = fullfile(p.pathname, [p.filename, p.num]);
            ext = p.PRINTFIGEXT{p.fileExt.getSelectedIndex + 1};
            printfig(p.hndl, ff, ext(2:end)) % print figure
            figure(p.frame) % Switch back to plotBrowser GUI
            % Increment counter
            fnum = str2double(p.num) + 1;
            if fnum < 10
                p.num = ['0', num2str(fnum)];
            else
                p.num = num2str(fnum);
            end
            p.counter.setText(p.num)
        end
        function hideObj(p, src, ~, obj)
            % Un/hides the un/selected object
            if src.isSelected 
                p.state.show(obj) % Delegate to selected state
                obj.UserData.hidden = false; % Set UserData for UI initialization
            else
                p.state.hide(obj)
                obj.UserData.hidden = true;
            end
        end
        function browseCallback(p, ~, ~)
            % Calls a file chooser that can be used for browsing to the
            % save destination path and stores the selected data for
            % exporting.
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
                % In case cancel button was clicked
            end
        end
        function chooseColor(p, src, ~)
            % Opens a color picker.
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
            % Callback for switching the State
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
            % Function for adding object adapters
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
            % Wrapper for simplifying the uiflowcontainer syntax
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
        % Wrappers for Java swing classes adapted to Matlab
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
        function [j, hcomponent, hcontainer, h] = JScrollList(container, str)
            % JList wrapped by a JScrollPane
            import javax.swing.* java.awt.*
            j = JList(str);
            j.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
            jsp = JScrollPane;
            jsp.setViewportView(j)
            [hcomponent, hcontainer] = javacomponent(jsp, [], container);
            if nargout == 4
                h = handle(j, 'CallbackProperties');
            end
        end
    end
    
    
    methods (Static)
        function s = getElementName(obj)
            % Returns a graphics object (or wrapper's) name for display
            % next to the check boxes.
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

