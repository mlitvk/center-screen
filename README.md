# Center Screen

Center the screen on the selected line, like `zz` in vim.

## How to use
Activate first by doing one of the following:
* Choosing `Center Screen: Center Screen` from the command palette
* Right click on the line you want to center, and choose `Center Screen` from the context menu
* Define a keyboard shortcut, for example:
```
'.editor':
    'ctrl-alt-z': 'center-screen:center-screen'
```

After that you can use these methods to center the selected line.

You can choose to keep the selected line centered when you move by using
the _Follow Cursor_ option in one of the following ways:
* Enable `Follow Cursor` in the settings for this package
* Choose `Center Screen: Toggle Follow Cursor` from the command palette
![center-screen screenshot](https://cloud.githubusercontent.com/assets/6184864/2947826/e850b426-d9fa-11e3-975a-916b7dc71135.gif)

## Credits
* [scroll-past-end](https://atom.io/packages/scroll-past-end) for the updateLayerDimensions idea
