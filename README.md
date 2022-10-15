# ppt_plotBrowser

> [![Maintenance](https://img.shields.io/badge/Maintained%3F-no-red.svg)](https://bitbucket.org/lbesson/ansi-colors)
>
> __NOTE:__
>
> Since I no longer use Matlab, I cannot actively maintain this model.
> I will gladly accept PRs, as long as I can review them without Matlab.

A similar tool to the Matlab plotbrowser inteded for the quick creation of images for PowerPoint animations.

To start the GUI, call

```matlab
  plotBrowser;
  
  plotBrowser(h); % on figure handle h

  p = plotBrowser(_); % to return a plotBrowser object that contains a cell array of the figure's children and sub-children.
```

NOTE: To use the export feature, the printfig function is required, which can be downloaded from here:

	https://github.com/MrcJkb/printfig.git
