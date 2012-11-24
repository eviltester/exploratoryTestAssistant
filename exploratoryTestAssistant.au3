;consolewrite(expandStringWithMacros(stripbackslashn("START_\nOF_@YYYYMMDD\n_@HHMM_HHMM_@APPDIR")))

; Exploratory Testing Assistant

;ctrl+shift+a to start screen capture

;setup mwsnap to autosave to folder

;send("^A")
; can we monitor the window?
; can we monitor a folder to check for a new file?

; To Do:
; change text when change a template
; have an 'expand macros now' menu option
; have an 'advanced - hide buttons, GUI option'

#include "n:\system_tools\autoit-v3\Include\GUIConstants.au3"
#Include "n:\system_tools\autoit-v3\Include\date.au3"

dim $iniFilePath
$iniFilePath = @ScriptDir & "\eta.ini"

;options
dim $optLogToFile
dim $optPromptOnExit
dim $optAppOpenHotKey
dim $optLogToClipBoard
dim $optHideOnCreateNote
dim $optClearTextOnCreateNote
dim $optDefaultLogFilePath
dim $optDefaultLogFileName
dim $optTextEditorPath
ProgressOn("Loading ETA", "Loading Options", "")

setOptionsFromINIFile()

func setOptionsFromINIFile()
	;set default options
	$optPromptOnExit = Number(IniRead($iniFilePath, "Options", "PromptOnExit", "1")) ; 1 = prompt, 0 = do not prompt
	$optAppOpenHotKey = IniRead($iniFilePath, "Options", "AppOpenHotKey", "^E")
	$optLogToClipBoard = Number(IniRead($iniFilePath, "Options", "LogToClipBoard", "1")) ; 0 = do not log to clipboard, 1 = log to clipboard
	$optHideOnCreateNote = Number(IniRead($iniFilePath, "Options", "HideWindowOnCreateNote", "1")) ; 0 = do not hide window after a create node, 1 = hide window	
	$optClearTextOnCreateNote = Number(IniRead($iniFilePath, "Options", "ClearTextOnCreateNote", "1")) ; 0 = do not clear text after a create node, 1 = do clear text
	$optDefaultLogFilePath = IniRead($iniFilePath, "Options", "DefaultLogFilePath", "@AppDir\")
	$optDefaultLogFileName = IniRead($iniFilePath, "Options", "DefaultLogFileName", "@YYYYMMDD_@HHMM.log")
	$optLogToFile = Number(IniRead($iniFilePath, "Options", "LogToFile", "1"))
	$optTextEditorPath = IniRead($iniFilePath, "Options", "textEditorPath", "notepad.exe")
EndFunc

func displayIni()
	
	$var = IniReadSection($iniFilePath, "Template:Bug")
	for $x = 1 to $var[0][0]
		ConsoleWrite($var[$x][1] & @lf)
	next
	
endfunc

; [templateID][0] = template name
; [templateID][1] = header text
; [templateID][2] = header text mode
; [templateID][3] = text mode
; [templateID][4] = text
; [templateID][5] = trailer text
; [templateID][6] = trailer text mode
dim $enum_TemplateName=0
dim $enum_TemplateHeaderText=1
dim $enum_TemplateHeaderTextMode=2	;Hidden, Visible
dim $enum_TemplateText=3
dim $enum_TemplateTextMode=4	
dim $enum_TemplateTrailerText=5
dim $enum_TemplateTrailerTextMode=6
dim $enum_TemplateAttributesCount=7

dim $templateNames[1][$enum_TemplateAttributesCount]
$templateNames[0][$enum_TemplateName] = "Unformatted"	; the default type - no formatting applied
$templateNames[0][$enum_TemplateHeaderText] = ""
$templateNames[0][$enum_TemplateText] = ""
$templateNames[0][$enum_TemplateTrailerText] = ""
$templateNames[0][$enum_TemplateHeaderTextMode] = "H"
$templateNames[0][$enum_TemplateTextMode] = "V"
$templateNames[0][$enum_TemplateTrailerTextMode] = "H"

ProgressSet (10, "Loading Templates", "Loading Templates")
setTemplatesFromINIFile()

func setTemplatesFromINIFile()
	;get all the template names
	$var = IniReadSectionNames($iniFilePath)
	
	ProgressSet (20, "Getting Template Names", "Loading Templates")
	
	$templateCount = 0
	;count all the Template: Names
	for $x = 0 to $var[0]
		if StringUpper(StringLeft($var[$x],9))=="TEMPLATE:" Then
			$templateCount = $templateCount +1
		endif 
	Next
	
	;redim the array
	redim $templateNames[$templateCount+1][$enum_TemplateAttributesCount]

	$progressStep = 70/$templateCount
	$progressIndicator = 20+$progressStep
	
	$templateCount = 1
	for $x = 0 to $var[0]
		if StringUpper(StringLeft($var[$x],9))=="TEMPLATE:" Then
			ProgressSet ($progressIndicator, stringmid($var[$x],10), "Loading Templates")
			$templateNames[$templateCount][$enum_TemplateName] = stringmid($var[$x],10)
			
			; get the rest of the template details
			$templateNames[$templateCount][$enum_TemplateHeaderText] = stripBackslashN(IniRead($iniFilePath, $var[$x], "headerText", ""))
			$templateNames[$templateCount][$enum_TemplateText] = stripBackslashN(IniRead($iniFilePath, $var[$x], "bodyText", ""))
			$templateNames[$templateCount][$enum_TemplateTrailerText] = stripBackslashN(IniRead($iniFilePath, $var[$x], "trailerText", ""))
			$templateNames[$templateCount][$enum_TemplateHeaderTextMode]  = IniRead($iniFilePath, $var[$x], "headerMode", "H")
			$templateNames[$templateCount][$enum_TemplateTextMode]  = IniRead($iniFilePath, $var[$x], "bodyMode", "V")
			$templateNames[$templateCount][$enum_TemplateTrailerTextMode]  = IniRead($iniFilePath, $var[$x], "trailerMode", "V")

			$templateCount = $templateCount +1
			$progressIndicator = $progressIndicator+$progressStep
		endif 
	Next	
endfunc	




dim $logFilePath 
dim $logFileName



dim $exitApp 
dim $exitWindow

$exitApp = 0
$exitWindow = 0




; GUI Controls and windows
dim $mainWindow
dim $templateCombo
dim $textEdit
dim $okbutton
dim $exitbutton

dim $chosenTemplateIndex

dim $mnuFile
dim $mnuFileExit
dim $mnuWindow
dim $mnuHideWindow
dim $mnuEdit
dim $mnuEditClearText
dim $mnuAddNote
dim $mnuLogToClipboard
dim $mnuFileEditOptions
dim $mnuNewLogFile
dim $mnuCloseLogFileText
dim $mnuLogToFile
dim $mnuOpenLogFileInEditor

$exitApp = 0
$exitWindow = 0

HotKeySet ( $optAppOpenHotKey, "addExploratoryNote" ) ; add exploratory note with ctrl+shift+E



ProgressSet (95, "Create Note Entry", "Initialise GUI")

dim $btnCreateNote
dim $btnHideText
dim $btnresetTextText
dim $btnExitApplicationText
dim $newLogFileText
dim $closeLogFileText
dim $reOpenLogFileText

setGUIFromINIFile()

createGUI()
ProgressSet (100, "Created GUI", "Initialise GUI")
ProgressOff()

addExploratoryNote()

while $exitApp==0
	Sleep(4000)  ; Idle around
WEnd

GUIDelete($mainWindow)
Exit




func setGUIFromINIFile()
	;set default options
	$btnCreateNote = IniRead($iniFilePath, "GUIText", "createNoteText", "Create &Note")
	$btnHideText = IniRead($iniFilePath, "GUIText", "hideText", "&Hide")
	$btnresetTextText = IniRead($iniFilePath, "GUIText", "resetTextText", "&Clear Text")
	$btnExitApplicationText = IniRead($iniFilePath, "GUIText", "exitApplicationText", "E&xit")
	$newLogFileText = IniRead($iniFilePath, "GUIText", "newLogFileText", "Create &New Log File")
	$closeLogFileText = IniRead($iniFilePath, "GUIText", "closeLogFileText", "Close Log File")
	$reOpenLogFileText = IniRead($iniFilePath, "GUIText", "openLogFileText", "&ReOpen Log File")
EndFunc

func openLogFileInEditor()
	if $logFilePath<>"" then
		run($optTextEditorPath & " " & $logFilePath & $logFileName)
	endif
EndFunc

func closeExistingFileCheck()
	if $logFilePath <> "" then
		if MsgBox(4,"Log File Currently Set","You are already using " & $logFileName & " in " & @lf & $logFilePath & @lf & "Are you sure you want to change this?")=6 Then
			return 1
		Else
			return 0
		EndIf
	EndIf
	return 1
endfunc 

func allocateDefaultFilePathAndName()
	if $logFilePath = "" Then
		$logFilePath = expandStringWithMacros($optDefaultLogFilePath)
		consoleWrite("Default Path " & $logFilePath & @lf)
	EndIf
	
	$logFileName = expandStringWithMacros($optDefaultLogFileName)
endfunc 

func getDefaultFilePathAndNameFrom($aFilePath)
	$splitPath = StringSplit($logFilePath,"\")
	$logFileName = $splitPath[$splitPath[0]]
	$logFilePath = StringTrimRight($logFilePath,stringlen($logFileName))
endfunc 

func createLogFile()
	$fileHandle = fileopen ($logFilePath & $logFileName,2)
	fileClose($fileHandle)
EndFunc

func setLogToFile($aBool)
		$optLogToFile = $aBool
		setGUIBasedOnLogToFile()	
endfunc 

func CreateNewLogFile()
	;do we already have a file?
	; ask if we want to close and add a new one
	if not closeExistingFileCheck() then
		return 0
	EndIf
	; $logFileName
	
	allocateDefaultFilePathAndName()
	
	;create a file dialog using the default file name options
	$logFilePath = FileSaveDialog("New Log File",$logFilePath,"All (*.*)",2+16, $logFileName)
	
	if not @error Then
		;create the new file
		getDefaultFilePathAndNameFrom($logFilePath)
		createLogFile()
		setLogToFile(1)
		return 1
	Else
		$logFileName = ""
		$logFilePath = ""
		setLogToFile(0)
		return 0
	EndIf
	
EndFunc

func ReOpenLogFile()
	;do we already have a file?
	; ask if you are sure? 
	if not closeExistingFileCheck() then
		return 0
	EndIf
	
	allocateDefaultFilePathAndName()
	
	$logFilePath = FileOpenDialog("Select Log File",$logFilePath,"All (*.*)",1+2)

	if not @error Then
		getDefaultFilePathAndNameFrom($logFilePath)
		setLogToFile(1)
		return 1
	Else
		$logFileName = ""
		$logFilePath = ""
		setLogToFile(0)
		return 0
	EndIf
		
EndFunc

func CloseLogFile()
	;do we already have a file?
	; ask if you are sure? 
	
	if not closeExistingFileCheck() then
		return 0
	EndIf
	
	$logFilePath = ""
	$logFileName = ""
	setLogToFile(0)
	
EndFunc

func logToFileDisabled()
	msgbox(1,"Disable Log To File","Log to file option will be temporarily" & @lf & "disabled. Set it using the Edit menu option")
	setLogToFile(0)
	return 0
endfunc 

func writeNoteToFile($aStringToWrite)
	
	if $logFilePath = "" then
		;if we do not have a file set then
		; no file set, do you want to create one?
		$createOne = msgbox(3,"No Output File Selected","Do you want to create a new log file?")
		select 
			case $createOne = 2 	;cancel
				return logToFileDisabled()
			case $createOne = 6		; Yes
				if not CreateNewLogFile() Then
					return logToFileDisabled()
				endif 
			case $createOne = 7		;No
				
		Endselect
		
		; if not then, do you want to use an existing one?
		$createOne = msgbox(3,"No Output File Selected","Do you want to use an existing log file?")
		select 
			case $createOne = 2 	;cancel
				return logToFileDisabled()
			case $createOne = 6		; Yes
				if not reopenLogFile() Then
					return logToFileDisabled()
				endif 
			case $createOne = 7		;No
				return logToFileDisabled() ; if not then, log to file option will be disabled
		Endselect
		
	endif 
	
	if $logFilePath <> "" then
		$fileHandle = fileopen ($logFilePath & $logFileName,1)
		filewriteline($fileHandle,$aStringToWrite)
		fileClose($fileHandle)
	endif 
		
EndFunc

func createGUI()
	Opt("GUIOnEventMode", 1)  ; Change to OnEvent mode 
	$mainWindow = GUICreate("Exploratory Test Assistant", 300, 400,-1,-1,$WS_SIZEBOX +$WS_SYSMENU)
	GUISetOnEvent($GUI_EVENT_CLOSE, "CloseWindowClicked")
	
	$mnuFile = GUICtrlCreateMenu ("&File")
	;New Log File
	$mnuNewLogFile = GUICtrlCreateMenuitem ($newLogFileText,$mnuFile)
	GUICtrlSetOnEvent($mnuNewLogFile, "CreateNewLogFile")

	;Close Log File
	$mnuCloseLogFileText = GUICtrlCreateMenuitem ($closeLogFileText,$mnuFile)
	GUICtrlSetOnEvent($mnuCloseLogFileText, "CloseLogFile")	
	
	;Reopen Log File
	$mnuReOpenLogFileText = GUICtrlCreateMenuitem ($reOpenLogFileText,$mnuFile)
	GUICtrlSetOnEvent($mnuReOpenLogFileText, "ReOpenLogFile")	
	
	GUICtrlCreateMenuitem ("",$mnuFile)
	;View Log File
	$mnuOpenLogFileInEditor = GUICtrlCreateMenuitem ("&View Log File",$mnuFile)
	GUICtrlSetOnEvent($mnuOpenLogFileInEditor, "OpenLogFileInEditor")
	
	GUICtrlCreateMenuitem ("",$mnuFile)
	
	$mnuFileEditOptions = GUICtrlCreateMenuitem ("Edit &Properties",$mnuFile)
	GUICtrlSetOnEvent($mnuFileEditOptions, "EditIniFile")
	GUICtrlCreateMenuitem ("",$mnuFile)
	$mnuFileExit = GUICtrlCreateMenuitem ($btnExitApplicationText,$mnuFile)
	GUICtrlSetOnEvent($mnuFileExit, "ExitApplication")

	$mnuEdit = GUICtrlCreateMenu ("&Edit")
	$mnuEditClearText = GUICtrlCreateMenuitem ($btnresetTextText,$mnuEdit)
	GUICtrlSetOnEvent($mnuEditClearText, "ResetTextToTemplateDefaults")
	$mnuAddNote = GUICtrlCreateMenuitem ($btnCreateNote,$mnuEdit)
	GUICtrlSetOnEvent($mnuAddNote, "CreateNoteButton")
	GUICtrlCreateMenuitem ("",$mnuEdit)
	$mnuLogToClipboard = GUICtrlCreateMenuitem ("Log To Clipboard",$mnuEdit)
	GUICtrlSetOnEvent($mnuLogToClipboard, "toggleLogToClipboard")
	setGUIBasedOnLogToClipboard()
	$mnuLogToFile = GUICtrlCreateMenuitem ("Log To File",$mnuEdit)
	GUICtrlSetOnEvent($mnuLogToFile, "toggleLogToFile")
	setGUIBasedOnLogToFile()
	
	$mnuWindow = GUICtrlCreateMenu ("&Window")
	$mnuHideWindow = GUICtrlCreateMenuitem ($btnHideText,$mnuWindow)	
	GUIctrlsetOnEvent($mnuHideWindow, "CloseWindowClicked")
	
	Opt ("GUICoordMode", 2)
	
	; log file stuff
	;GUICtrlCreateLabel("LogFile", 30, 10)
	
	;template dropdown

	$templateCombo = GUICtrlCreateCombo ($templateNames[0][$enum_TemplateName], 10,10,100,30,$CBS_SIMPLE + $CBS_DROPDOWN) ; create first item + $CBS_DROPDOWNLIST to have an edited list
	GUIctrlsetOnEvent($templateCombo, "TemplateComboChanged")
	$chosenTemplateIndex = 0
	for $templatesIterator = 1 to ubound($templateNames) -1
		GUICtrlSetData($templateCombo,$templateNames[$templatesIterator][$enum_TemplateName]) ; add other item
	next 
	GUICtrlSetResizing($templateCombo,$GUI_DOCKSIZE)
	
	Opt ("GUICoordMode", 1)
	;text entry
	$textEdit = GUICtrlCreateEdit("",10,40,280,250,$WS_VSCROLL+$ES_MULTILINE+$ES_AUTOVSCROLL+$ES_WANTRETURN)
	GUICtrlSetResizing($textEdit,$GUI_DOCKLEFT + $GUI_DOCKTOP)	
	
	Opt ("GUICoordMode", 2)
	;action buttons
	$okbutton = GUICtrlCreateButton($btnCreateNote, -1, 0,100,20)
	GUICtrlSetOnEvent($okbutton, "CreateNoteButton")
	GUICtrlSetResizing($okbutton,$GUI_DOCKLEFT + $GUI_DOCKWIDTH )

	$hideButton = GUICtrlCreateButton($btnHideText, 0, -1,100,20)
	GUICtrlSetOnEvent($hideButton, "CloseWindowClicked")
	GUICtrlSetResizing($hideButton,$GUI_DOCKLEFT + $GUI_DOCKWIDTH )
	
	$clearButton = GUICtrlCreateButton($btnresetTextText, 0, -1, 100,20)
	GUICtrlSetOnEvent($clearButton, "ResetTextToTemplateDefaults")
	GUICtrlSetResizing($clearButton, $GUI_DOCKLEFT + $GUI_DOCKWIDTH )	

		;action buttons
	$exitbutton = GUICtrlCreateButton($btnExitApplicationText, -1, 0,100,20)
	GUICtrlSetOnEvent($exitbutton, "ExitApplication")
	GUICtrlSetResizing($exitbutton,$GUI_DOCKLEFT + $GUI_DOCKWIDTH)
	
EndFunc	

func TemplateComboChanged()
	$newTemplateIndex = templateNameIndex(GUICtrlRead($templateCombo))
	if $newTemplateIndex <> $chosenTemplateIndex Then
		;change it
		ResetTextToTemplateDefaults()
	EndIf
EndFunc

func EditIniFile()
	run($optTextEditorPath & " " & $iniFilePath)
endfunc 

func toggleLogToClipboard()
	$optLogToClipboard = not $optLogToClipboard
	setGUIBasedOnLogToClipboard()
EndFunc

func setGUIBasedOnLogToClipboard()
	if $optLogToClipboard Then
		GUICtrlSetState($mnuLogToClipboard,$GUI_CHECKED)
	Else
		GUICtrlSetState($mnuLogToClipboard,$GUI_UNCHECKED)
	EndIf
EndFunc

func setGUIBasedOnLogToFile()
	if $optLogToFile Then
		GUICtrlSetState($mnuLogToFile,$GUI_CHECKED)
	Else
		GUICtrlSetState($mnuLogToFile,$GUI_UNCHECKED)
	EndIf
EndFunc

func toggleLogToFile()
	$optLogToFile = not $optLogToFile
	setGUIBasedOnLogToFile()
EndFunc


func addExploratoryNote()

	; show it
	GUISetState(@SW_SHOWNORMAL , $mainwindow)
	WinActivate($mainwindow)
	
endfunc

func templateNameIndex($aTemplateName)
	;find the template in the list
	dim $foundIt
	
	$foundIt = 0	; if name not found then use the unformatted template
	
	for $x = 0 to ubound($templateNames)
		if $templateNames[$x][$enum_TemplateName]=$aTemplateName Then
			$foundIt = $x
			ExitLoop
		endif
	next 
	
	return $foundIt
EndFunc

func ResetTextToTemplateDefaults()
	; actually reset to template defaults
		
	$chosenTemplateIndex = templateNameIndex(GUICtrlRead($templateCombo))
	$textToEdit = ""
	
	if stringupper(stringleft($templateNames[$chosenTemplateIndex][$enum_TemplateHeaderTextMode],1)) = "V" then
		if $templateNames[$chosenTemplateIndex][$enum_TemplateHeaderText] <> "" then
			$textToEdit = $textToEdit & $templateNames[$chosenTemplateIndex][$enum_TemplateHeaderText] & @CRLF
		endif
	EndIf

	if stringupper(stringleft($templateNames[$chosenTemplateIndex][$enum_TemplateTextMode],1)) = "V" then
		if $templateNames[$chosenTemplateIndex][$enum_TemplateText] <> "" then
			$textToEdit = $textToEdit & $templateNames[$chosenTemplateIndex][$enum_TemplateText] & @CRLF
		endif
	EndIf

	if stringupper(stringleft($templateNames[$chosenTemplateIndex][$enum_TemplateTrailerTextMode],1)) = "V" then
		if $templateNames[$chosenTemplateIndex][$enum_TemplateTrailerText] <> "" then
			$textToEdit = $textToEdit & $templateNames[$chosenTemplateIndex][$enum_TemplateTrailerText] & @CRLF
		endif
	EndIf
		
	GUICtrlSetData($textEdit,$textToEdit)
	
EndFunc

func CloseWindowClicked()
	; should really just minimise the gui here
	GUISetState(@SW_HIDE, $mainWindow)
EndFunc

func ExitApplication()
	
	if $optPromptOnExit then 
		if MsgBox(4, "Confirm Application Exit","Are you sure you want to Exit?") <> 6 then ; they pressed no
			return 0
		endif 
	endif 
	
	$exitApp = 1
	return 1
EndFunc

func CreateNoteButton()
	
	dim $outputString
	dim $addedHeader
	dim $addedBody
	dim $addedTrailer

	$chosenTemplateIndex = templateNameIndex(GUICtrlRead($templateCombo))
	$outputString = ""
	
	$addedHeader = 0
	$addedBody = 0
	$addedTrailer = 0
	
	; if it was hidden then make visible
	if stringupper(stringleft($templateNames[$chosenTemplateIndex][$enum_TemplateTrailerTextMode],1)) = "H" then
		if $templateNames[$chosenTemplateIndex][$enum_TemplateHeaderText] <> "" then
			$outputString = $outputString & expandStringWithMacros($templateNames[$chosenTemplateIndex][$enum_TemplateHeaderText])
			$addedHeader = 1
		endif
	endif

	; body is always visible
	;if $templateNames[$chosenTemplateIndex][$enum_TemplateText] <> "" then
		if $addedHeader = 1 Then
			$outputString = $outputString & @CRLF
		EndIf
		$outputString = $outputString & expandStringWithMacros(GUICtrlRead($textEdit)) 
		$addedBody = 1
	;endif


	if stringupper(stringleft($templateNames[$chosenTemplateIndex][$enum_TemplateTrailerTextMode],1)) = "H" then
		if $templateNames[$chosenTemplateIndex][$enum_TemplateTrailerText] <> "" then
			if $addedBody = 1 Then
				$outputString = $outputString & @CRLF
			EndIf
			$outputString = $outputString & expandStringWithMacros($templateNames[$chosenTemplateIndex][$enum_TemplateTrailerText])
		endif
	EndIf


	
	
	if $optLogToFile then 
		writeNoteToFile($outputString)
	EndIf
		
	if $optLogToClipBoard then 
		clipput($outputString)
	EndIf
	
	if $optClearTextOnCreateNote Then
		ResetTextToTemplateDefaults()
	EndIf
	
	if $optHideOnCreateNote Then
		CloseWindowClicked()
	EndIf 
	
endfunc 

func stripBackslashN($aString)
	
	if $aString = "" Then
		return ""
	EndIf
	
	$values = stringSplit($aString,"\n",1)
	$retValue = ""
	
	for $x = 1 to $values[0]
		$retValue = $retValue & $values[$x] &  @CRlf
	Next

	return $retValue
	
EndFunc

func expandStringWithMacros($aString)

	dim $macroStartAt
	dim $lastChar
	dim $retString
	
	$lastChar = ""
	$macroStartAt = 0
	$retString = ""
	
	for $x = 1 to stringlen($aString)
		select 
		case stringmid($aString,$x,1)=="@" 
			if $lastChar <> "\" then
				; we found the start of a macro
				if $macroStartAt <> 0 Then
					;already processing a macro
					; so process it first
					$retString = $retString & expandMacro(stringmid($aString,$macroStartAt, $x-$macroStartAt))
				EndIf
				$macroStartAt = $x+1
			EndIf
		case not StringIsAlpha(stringmid($astring,$x,1))
			if $macroStartAt then
				; we found the end of a macro
				$retString = $retString & expandMacro(stringmid($aString,$macroStartAt, $x-$macroStartAt))
				$macroStartAt=0
				$retString = $retString & stringmid($aString,$x,1)  ; add the char we just found
			Else
				$retString = $retString & stringmid($aString,$x,1)
			endif 
			
		case Else
			;if we have found a macro then process it here
			if $macroStartAt Then
				; queue the character for later processing
			Else
				$retString = $retString & stringmid($aString,$x,1)
			endif
		EndSelect
		
		$lastChar = stringmid($aString,$x,1)
		
	next 
	
	if $macroStartAt Then
		;we have an unprocessed macro name
		$retString = $retString & expandMacro(stringmid($aString,$macroStartAt))
	EndIf
	
	return $retString
		
endfunc 



func expandMacro($macroName)

	ConsoleWrite("Expanding Macro " & $macroName & @LF)
	
	; expand macro names to the equivalents
	$ucMacroName = StringUpper($macroName)
	
	select 
	case $ucMacroName = "APPDIR"
		return @ScriptDir
	case $ucMacroName = "YYYYMMDD"
		return @YEAR & @MON & @MDAY
	case $ucMacroName = "HHMM"
		return @HOUR & @MIN
	case $ucMacroName = "NULL"
		return ""
	case $ucMacroName = "CURRENTDATE"
		return _NowDate()
	case $ucMacroName = "CURRENTTIME"
		return _NowTime()
	case Else
		;macro name not found
		return "@" & $macroName
	EndSelect
endfunc 

#cs
HotKeys to:

HotKey Per Template
Add * [show a menu of all templates]
Add <specific template> Show dialog 

\config
config.ini
{key}	\templates\bug.txt
{key}	START_LOG
{key}	STOP_LOG
{key}	CONFIG
{key}	ADD_NOTE


options to use:
mwsnap
counterstring


a Note always has the format
----Note: !!CurrentDateTime----

[TEMPLATES]
[TEMPLATE]
#NAME:BUG
#MODE:ExpandTagsOnCreate
#MODE:ExpandTagsOnSave
#PRE
#TEXT
#POST

\templates
template file
bug.txt
Title: Add Bug
Text: Description
Output:
#BUG
!!Text
!!CurrentTime
!!CurrentDate
!!CurrentDateTime

other templates
issue.txt
Title: Add Issue
Text: Description
Output:
#ISSUE
!!Text
!!CurrentTime
!!CurrentDate
!!CurrentDateTime

\system_templates
System Templates
startlog.txt
--Start Log !!CurrentDateTime

stoplog.txt
--Stop Log !!CurrentDateTime

pauselog.txt
-- Paused Log @ !!CurrentDateTime

continuelog.txt
-- Continue Log @ !!CurrentDateTime



#ce