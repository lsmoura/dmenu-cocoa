dmenu-cocoa
===========
an efficient dynamic menu for macOS

requirements
------------
in order to build this project, you need to have
make and the xcode command line tools installed.

running
-------
execute the binary passing a list of options to display,
separated by newlines. by default, the window will be
displayed at the top of the screen, horizontally.

* `-b` to display the menu at the bottom of the screen
* `-l <number>` to display a vertical list of options
* `-i` to ignore case when matching options
* `-p <prompt>` to display a prompt before the options
* `-fn <font>` to set the font used in the menu
* `-nb <color>` to set the background color of the menu
* `-nf <color>` to set the foreground color of the menu
* `-sb <color>` to set the background color of the selected option
* `-sf <color>` to set the foreground color of the selected option
* `-v` to display the version and exit
