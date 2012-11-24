Exploratory Test Assistant (ETA)
================================

Exploratory Test Assistant - autoit script for making notes while engaged in exploratory testing



Basically this is a small application to allow the jotting down of notes
during exploratory testing. Notes can be logged to a text file and to the
clipboard. Notes are generated according to user defined templates.

Most actions can be controlled by the keyboard.

Log entries are written to the end of the associated log file.

A drop down shows the current template in use.

The text area is the note to create.

Configuration via the eta.ini file.

This is a prototype to experiment with and build on. By using templates
the generated log files can be parsed be other apps on various sites for report generation etc.

Aims:
- Majority of functionality keyboard driven
- Low memory footprint
- Useful in exploratory testing
- encourage note taking
- ease note taking
- portal for exploratory testing tools and tool launching

Possible future features:
- Keylogging (at discrete points in a process)
 - embed results in the log file
- screencapture - embed filenames in the log file
- integrate with other exploratory test tools
  - screencapture
  - counterstring
  - timers, alerts
- functionality from testing spreadsheet on compendium dev
- multiple configuration files
- apply configuration file changes without restarting app
- tail log file
- more macros
- documentation
- template files instead of all in the config file e.g. \templates\bug.txt


Startup
-------
After starting eta.exe, GUI will be shown.

Usage
-----

Defaults:

(these can all be changed by amending the BUI button text and changing the & position)
Alt+L will create a log entry
Alt+H will hide the GUI
Alt+R will reset the text to the template defaults
Alt+X will exit the application

Once hidden. ETA will be running in the background. use hot key Ctrl+Shift+E to show the GUI (You can amend this by changing the AppOpenHotKey in eta.ini).

Menu
----
File:
Create New Log File - create a new file and associate it with the application as the current log file.
Close Log File - no file will be associated with the app
ReOpen Log File - associate an existing file with the app for logging to.

View Log File - open the log file in the associated text editor (or notepad - default)

Edit Properties - edit the properties (config) file in a text editor. Changes are only applied when the app is restarted.

Exit - exit the application

Edit:
Reset Template - reset the text to the template defaults
Create Log - create a log entry

Log To clipboard - log entries are sent to the clipboard when set
Log to file - log entries are sent to the associated log file when set

Window:
Hide - hide the window and leave the app running in the background. Ctrl+Shift+E to show GUI


Config File
-----------
eta.ini is the config file.

true false values are 0 for false, 1 for true
leave a value blank to use the default

Macros
- @AppDir - the directory of the application without a trailing \
- @YYYYMMDD - current date in YYYYMMDD format-
- @HHMM - current time in HHMM format
- @CurrentDate - current date in system format
- @CurrentTime - current time in system format

Templates are used to define what type of notes can be created and the format of them.

Templates have a name
```
[Template:<name>]
```

A header, body and trailer

Header and trailer can be hidden by setting the mode to H or Hidden.

Macros can be embedded in the templates. Create new lines in the templates with \n - each 
config entry must be on a single line in the file.

Use your favourite editor by amending textEditorPath in eta.ini e.g. c:\notepad++.exe


Licensed Under Apache 2.0
--------------------------


Copyright 2006 Alan Richardson - Compendium Developments

Copyright [yyyy] [name of copyright owner]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
