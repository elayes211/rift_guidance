#RequireAdmin
#include "_ImageSearch_UDF.au3"
#include "_ImageSearch_Tool.au3"
; Author
; Pipiou211
; Thanks to foggedftw for the data to work with, his Excel for shaco.
; v4 version

;AdlibRegister("check", 1)
Global $enemy
Func check()
    If StringInStr(GUICtrlRead($enemy), " ") Then
        GUICtrlSetData($enemy, StringTrimRight(GUICtrlRead($enemy), 1))
    EndIf
 EndFunc



#AutoIt3Wrapper_Icon=icon.ico
;!Highly recommended for improved overall performance and responsiveness of the GUI effects etc.! (after compiling):
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /rm /pe

;YOU NEED TO EXCLUDE FOLLOWING FUNCTIONS FROM AU3STRIPPER, OTHERWISE IT WON'T WORK:
#Au3Stripper_Ignore_Funcs=_iHoverOn,_iHoverOff,_iFullscreenToggleBtn,_cHvr_CSCP_X64,_cHvr_CSCP_X86,_iControlDelete
;Please not that Au3Stripper will show errors. You can ignore them as long as you use the above Au3Stripper_Ignore_Funcs parameters.

;Required if you want High DPI scaling enabled. (Also requries _Metro_EnableHighDPIScaling())
#AutoIt3Wrapper_Res_HiDpi=y

#NoTrayIcon
#Include <Misc.au3>
#include <Required/Restart.au3>
#include <Array.au3>
#include <Excel.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstants.au3>

Local $hDLL = DllOpen("user32.dll")

#include "Required/MetroGUI/MetroGUI_UDF.au3"
#include "Required/MetroGUI/_GUIDisable.au3" ; For dim effects when msgbox is displayed

Local Const $appName = "Rift Guidance"
_Singleton($appName)
Local Const $themeFile = @ScriptDir & "\themeSetting.txt"
Local Const $autoQueueFile = @ScriptDir & "\autoQueueSetting.txt"
Local Const $clientPathFile = @ScriptDir & "\clientPath.txt"
Local Const $championSettingFile = @ScriptDir & "\championSetting.txt"
Local $championSetting
Local $autoQueue = "off" ; Initialization in case that autoQueueSetting.txt does not exist
Local $autoPinkWardTrinket = "on"
Local $savedTheme = FileReadLine($themeFile, 1)
Local $clientPath = FileReadLine($clientPathFile, 1)
Global $autoqueuePID
Global $pinkwardandtrinketPID
Global $enemy
Global $search

; Enables and/or disables Data and Wifi switching
Global $data_switch_frag = False
Global $on_data = 0

Global $excelFile

_ChampionSelectedCheck()

;=======================================================================Creating the GUI===============================================================================
;Enable high DPI support: Detects the users DPI settings and resizes GUI and all controls to look perfectly sharp.
_Metro_EnableHighDPIScaling() ; Note: Requries "#AutoIt3Wrapper_Res_HiDpi=y" for compiling. To see visible changes without compiling, you have to disable dpi scaling in compatibility settings of Autoit3.exe

; Try run
Run($clientPath & "\Riot Client\RiotClientServices.exe --launch-product=league_of_legends --launch-patchline=live")
While 1
   _AutoQueueCheck()
   _LoadAndSetTheme()
   _CreateEnemyDefineGUI()
   _CreateGUI($search)
WEnd

Func _LoadAndSetTheme()
   $savedTheme = FileReadLine($themeFile, 1);
   If $savedTheme == "" Then
	  FileWrite($themeFile, "DarkMidnightTeal")
	  FileClose($themeFile)
   EndIf
   _SetTheme($savedTheme)
EndFunc

Func _AutoQueueCheck()
   $autoqueuePID = Null
   $pinkwardandtrinketPID = Null
   If FileExists($autoQueueFile) then
	  $autoQueue = FileReadLine($autoQueueFile, 1);
	  If $autoQueue == "on" Then
		 $autoqueuePID = Run(@ScriptDir & "\Required\AutoQueue.exe")
	  EndIf
	  If $autoPinkWardTrinket == "on" Then
		 $pinkwardandtrinketPID = Run(@ScriptDir & "\Required\PinkWardTrinket.exe")
	  EndIf
   Else
	  FileDelete($autoQueueFile)
	  FileWriteLine($autoQueueFile, "off")
	  FileWriteLine($autoQueueFile, "50")
	  FileClose($autoQueueFile)
   EndIf
EndFunc

Func _ChampionSelectedCheck()
   If FileExists($championSettingFile) then
	  $championSetting = FileReadLine($championSettingFile, 1);
	  If $championSetting == "tryndamere_top" Then
		 $excelFile = "Data\tryndamere_top.xlsx"
	  ElseIf $championSetting == "tryndamere_mid" Then
		 $excelFile = "Data\tryndamere_mid.xlsx"
	  ElseIf $championSetting == "shaco" Then
		 $excelFile = "Data\shaco.xlsx"
	  ElseIf $championSetting == "thresh" Then
		 $excelFile = "Data\thresh.xlsx"
	  ElseIf $championSetting == "zyra" Then
		 $excelFile = "Data\zyra.xlsx"
	  EndIf

	  ; Create application object and open an example workbook
	  Global $oExcel = _Excel_Open(False)
	  If @error Then Exit _Metro_MsgBox(0, $appName, "Are you sure you have Microsoft Excel installed?" & @CRLF &  "OpenOffice might work as well, google it.", 350, 11, Default)
	  Global $oWorkbook = _Excel_BookOpen($oExcel, @ScriptDir & "\" & $excelFile)
	  If @error Then Exit _Metro_MsgBox(0, $appName, "Error opening the " & $excelFile & " file." & @CRLF & "Are you sure it is located in the Data folder with the .exe?", 350, 11, Default)

	  ProcessClose($autoqueuePID)
	  ProcessClose($pinkwardandtrinketPID)
   Else
	  _SelectChampion()
   EndIf
EndFunc

Func _SelectChampion()
	  Local $SelectChampionForm = _Metro_CreateGUI($appName, 430, 165, -1, -1, False)
	  Local $Control_Buttons = _Metro_AddControlButtons(True, False, False, False, False) ;CloseBtn = True, MaximizeBtn = True, MinimizeBtn = True, FullscreenBtn = True, MenuBtn = True

	  GUISetState(@SW_SHOW)
	  $font="Open Sans"
	  GUISetFont (14, 400, 2, $font); will display underlined characters
	  Local $question = GUICtrlCreateLabel("Which champion will you be playing?", 20,15+25)
	  GUICtrlSetColor(-1, $ButtonBKColor)
	  Local $aPos = ControlGetPos("", "", $question)
	  Local $tryndamere_top = _Metro_CreateButtonEx2("Trynda Top", $aPos[0], $aPos[1]+30, 90, 30)
	  Local $aPos = ControlGetPos("", "", $tryndamere_top)
	  Local $tryndamere_mid = _Metro_CreateButtonEx2("Trynda Mid", $aPos[0]+$aPos[2], $aPos[1], 90, 30)
	  Local $aPos = ControlGetPos("", "", $tryndamere_mid)
	  Local $shaco = _Metro_CreateButtonEx2("Shaco", $aPos[0]+$aPos[2], $aPos[1], 90, 30)
	  Local $aPos = ControlGetPos("", "", $shaco)
	  Local $thresh = _Metro_CreateButtonEx2("Thresh", $aPos[0]+$aPos[2], $aPos[1], 90, 30)
	  Local $aPos = ControlGetPos("", "", $thresh)
	  Local $zyra = _Metro_CreateButtonEx2("Zyra", $aPos[0]+$aPos[2], $aPos[1], 90, 30)
	  ;$excelFile = "Data\tryndamere_top.xlsx"
	  ;$excelFile = "Data\tryndamere_mid.xlsx"
	  ;$excelFile = "Data\shaco.xlsx"
	  ;$excelFile = "Data\thresh.xlsx"
	  ;$excelFile = "Data\zyra.xlsx"

	  $GUI_CLOSE_BUTTON = $Control_Buttons[0]
	  While 1
	   $nMsg = GUIGetMsg()
		  Switch $nMsg
			  Case $GUI_EVENT_CLOSE
				  ProcessClose($autoqueuePID)
				  ProcessClose($pinkwardandtrinketPID)
				  Exit
			  Case $GUI_CLOSE_BUTTON
				  _Metro_GUIDelete($SelectChampionForm)
				  ExitLoop
			  Case $tryndamere_top
					 FileDelete($championSettingFile)
					 FileWriteLine($championSettingFile, "tryndamere_top")
					 FileClose($championSettingFile)
					 _Metro_GUIDelete($SelectChampionForm)
					 _ChampionSelectedCheck()
					 ExitLoop
			  Case $tryndamere_mid
					 FileDelete($championSettingFile)
					 FileWriteLine($championSettingFile, "tryndamere_mid")
					 FileClose($championSettingFile)
					 _Metro_GUIDelete($SelectChampionForm)
					 _ChampionSelectedCheck()
					 ExitLoop
			  Case $shaco
					 FileDelete($championSettingFile)
					 FileWriteLine($championSettingFile, "shaco")
					 FileClose($championSettingFile)
					 _Metro_GUIDelete($SelectChampionForm)
					 _ChampionSelectedCheck()
					 ExitLoop
			  Case $thresh
					 FileDelete($championSettingFile)
					 FileWriteLine($championSettingFile, "thresh")
					 FileClose($championSettingFile)
					 _Metro_GUIDelete($SelectChampionForm)
					 _ChampionSelectedCheck()
					 ExitLoop
			  Case $zyra
					 FileDelete($championSettingFile)
					 FileWriteLine($championSettingFile, "zyra")
					 FileClose($championSettingFile)
					 _Metro_GUIDelete($SelectChampionForm)
					 _ChampionSelectedCheck()
					 ExitLoop
			EndSwitch
	  WEnd

EndFunc

Func _SelectClientPath()
   Local $clientPath = ""
   Local $running = 0
   While $running == 0
	  _Metro_MsgBox(0, $appName, "Please select your Riot Games folder.", 350, 13, Default)
	  $clientPath = FileSelectFolder("Select the Riot Games folder", "C:\")
	  If @error Then
        ; Display the error message.
		_Metro_MsgBox(0, $appName, "No folder was selected.", 350, 13, Default)
		Return ""
	  EndIf
	  $running = Run($clientPath & "\Riot Client\RiotClientServices.exe --launch-product=league_of_legends --launch-patchline=live")
	  If $running == 0 Then
		_Metro_MsgBox(0, $appName, "Wrong folder has been selected.", 350, 13, Default)
		Return ""
	  EndIf
   WEnd
   Return $clientPath
EndFunc

Func _SearchIntoTheExcel()
	  $search = _Excel_RangeFind($oWorkbook, GUICtrlRead($enemy), "A1:A170")
	  $iIndex = _ArraySearch($search, GUICtrlRead($enemy), 0, 0, 0, 0, 1, 3, True)
	  If $iIndex == -1 Then
		 Return 0
	  Else
		 Return 1
	  EndIf
   EndFunc

Func _MenuLoop($form, $first_form, $button, $control_menu_buttons)
	  $GUI_CLOSE_BUTTON = $control_menu_buttons[0]
	  $GUI_MAXIMIZE_BUTTON = $control_menu_buttons[1]
	  $GUI_RESTORE_BUTTON = $control_menu_buttons[2]
	  $GUI_MINIMIZE_BUTTON = $control_menu_buttons[3]
	  $GUI_FULLSCREEN_BUTTON = $control_menu_buttons[4]
	  $GUI_FSRestore_BUTTON = $control_menu_buttons[5]
	  $GUI_MENU_BUTTON = $control_menu_buttons[6]

      While 1
		 If $autoQueue == "on" Then
			If WinExists("League of Legends (TM) Client") Then
			   If $on_data == 0 and $data_switch_frag == True Then
				  Run("C:\Quick Load Games\Tryndamere's Right Arm\Required\adb\on_data.bat")
				  $on_data = 1
			   EndIf
			Else
			   If $on_data == 1 and $data_switch_frag == True Then
				  Run("C:\Quick Load Games\Tryndamere's Right Arm\Required\adb\on_wifi.bat")
				  $on_data = 0
			   EndIf
			EndIf
		 EndIf


		 If ProcessExists($autoqueuePID) == 0 and $autoQueue == "on" Then
			$autoqueuePID = Run(@ScriptDir & "\Required\AutoQueue.exe")
		 EndIf
		 If ProcessExists($pinkwardandtrinketPID) == 0 and $autoPinkWardTrinket == "on" Then
			$pinkwardandtrinketPID = Run(@ScriptDir & "\Required\PinkWardTrinket.exe")
		 EndIf

		  If _IsPressed("0D", $hDLL) and WinActive($appName)  Then
			   If $first_form == 0 Then
				  _ScriptRestart($autoqueuePID, $pinkwardandtrinketPID)
			   ElseIf $first_form == 1 Then
				  If (GUICtrlRead($enemy) == "") Then
				  Else
					 If _SearchIntoTheExcel() == 1 Then
						ExitLoop
					 Else
						_Metro_MsgBox(0, $appName, "The enemy you specified cannot be found in the .xlsx File.", 350, 11, Default)
					 EndIf
				  EndIf
			   EndIf
		 EndIf

		  $nMsg = GUIGetMsg()
		  Switch $nMsg
			  Case $button
				  If $first_form == 1 Then
					 If (GUICtrlRead($enemy) == "") and $first_form == 1 Then
						_Metro_MsgBox(0, $appName, "Please enter a champion name.", 350, 11, $form)
					 Else
						If _SearchIntoTheExcel() == 1 Then
						   ExitLoop
						Else
						   _Metro_MsgBox(0, $appName, "The enemy you specified cannot be found in the .xlsx File.", 350, 11, Default)
						EndIf
					 EndIf
				  ElseIf $first_form == 0 Then
						_ScriptRestart($autoqueuePID, $pinkwardandtrinketPID)
				  EndIf
			  Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON
				  ProcessClose($autoqueuePID)
				  ProcessClose($pinkwardandtrinketPID)
				  Exit
			  Case $GUI_MAXIMIZE_BUTTON
				  GUISetState(@SW_MAXIMIZE, $form)
			  Case $GUI_MINIMIZE_BUTTON
				  GUISetState(@SW_MINIMIZE, $form)
			  Case $GUI_RESTORE_BUTTON
				  GUISetState(@SW_RESTORE, $form)
			  Case $GUI_MENU_BUTTON
				  ;Create an Array containing menu button names
				  Local $MenuButtonsArray[5] = ["Change Champion", "Run Launcher", "Change Theme", 'Toggle AutoQueue', "About"]
				  Local $MenuSelect = _Metro_MenuStart($form, 150, $MenuButtonsArray)
				  Switch $MenuSelect ;Above function returns the index number of the selected button from the provided buttons array.
				  Case "0"
					 _SelectChampion()
				  Case "1"
					 If $clientPath == "" or Run($clientPath & "\Riot Client\RiotClientServices.exe --launch-product=league_of_legends --launch-patchline=live") == 0 Then
						$clientPath = _SelectClientPath()
						If $clientPath <> "" Then
							FileDelete($clientPathFile)
							FileWrite($clientPathFile, $clientPath)
							FileClose($clientPathFile)
						EndIf
					 EndIf
				  Case "2"
					  GUISetState($form, @SW_LOCK)
					  Local $ThemesArray[25] = ["DarkMidnightTeal", "DarkMidnightBlue", "DarkMidnightCyan", "DarkMidnight", "DarkTeal", "DarkBlueV2", "DarkBlue", "DarkCyan", "DarkRuby", "DarkGray", "DarkGreen", "DarkGreenV2", "DarkPurple", "DarkAmber", "DarkOrange", "LightTeal", "LightGray", "LightBlue", "LightCyan", "LightGreen", "LightRed", "LightOrange", "LightPurple", "LightPink", "DarkTealV2"]
					  Local $nextThemeIndex = _ArraySearch($ThemesArray, $savedTheme)+1
					  if $nextThemeIndex > 24 Then
						$nextThemeIndex = 0
					  EndIf
					  Local $nextTheme = $ThemesArray[$nextThemeIndex]
					  FileDelete($themeFile)
					  FileWrite($themeFile, $nextTheme)
					  FileClose($themeFile)
					  _ScriptRestart($autoqueuePID, $pinkwardandtrinketPID)
				  Case "3"
					 If $autoQueue == "off" Then
						FileDelete($autoQueueFile)
						FileWriteLine($autoQueueFile, "on")
						FileWriteLine($autoQueueFile, "50")
						FileClose($autoQueueFile)
						_ScriptRestart($autoqueuePID, $pinkwardandtrinketPID)
					 Else
						FileDelete($autoQueueFile)
						FileWriteLine($autoQueueFile, "off")
						FileWriteLine($autoQueueFile, "50")
						FileClose($autoQueueFile)
						_ScriptRestart($autoqueuePID, $pinkwardandtrinketPID)
					 EndIf
				  Case "4"
					 _Metro_MsgBox(0, $appName, "This application is a creation of Pipiou211. All rights reserved.", 350, 11, $form)
					 ShellExecute("https://www.reddit.com/r/shacoMains/comments/hd6xhg/foggedftws_guide_app/")
				 EndSwitch
			  Case $GUI_FULLSCREEN_BUTTON, $GUI_FSRestore_BUTTON
				  ;ConsoleWrite("Fullscreen toggled" & @CRLF) ;Fullscreen toggle is processed automatically when $ControlBtnsAutoMode is set to true, otherwise you need to use here _Metro_FullscreenToggle($form)
		 EndSwitch
   WEnd
EndFunc

Func _CreateEnemyDefineGUI()
   Local $EnemyDefineForm = _Metro_CreateGUI($appName, 430, 165, -1, -1, False)
   ;Add/create control buttons to the GUI
   Local $Control_Buttons_EnemyDefineForm = _Metro_AddControlButtons(True, True, True, False, True) ;CloseBtn = True, MaximizeBtn = True, MinimizeBtn = True, FullscreenBtn = True, MenuBtn = True
   $font="Open Sans"
   GUISetFont (14, 400, 2, $font); will display underlined characters
   Local $question
	  If $championSetting == "tryndamere_top" Then
		 $question = GUICtrlCreateLabel("Which champion will be your enemy at toplane?", 20,15+25)
	  ElseIf $championSetting == "tryndamere_mid" Then
		 $question = GUICtrlCreateLabel("Which champion will be your enemy at midlane?", 20,15+25)
	  ElseIf $championSetting == "shaco" Then
		 $question = GUICtrlCreateLabel("Which champion will be your enemy at jungle?", 20,15+25)
	  ElseIf $championSetting == "thresh" Then
		 $question = GUICtrlCreateLabel("Which champion will be your enemy at botlane?", 20,15+25)
	  ElseIf $championSetting == "zyra" Then
		 $question = GUICtrlCreateLabel("Which champion will be your enemy at botlane?", 20,15+25)
	  EndIf
   GUICtrlSetColor(-1, $ButtonBKColor)
   $enemy = GUICtrlCreateInput("", 20+5, 66+10, 307, 25)
   GUISetState(@SW_SHOW)
   Local $aPos = ControlGetPos("", "", $enemy)
   ;Local $OK = GUICtrlCreateButton("OK", $aPos[0]+$aPos[2]+5, $aPos[1], 50, 25)
   Local $OK = _Metro_CreateButtonEx2("OK", $aPos[0]+$aPos[2]+5, $aPos[1]-3.2, 50, 30)
   Local $aPos = ControlGetPos("", "", $EnemyDefineForm)
   GUISetFont (12, 400, 2, $font); will display underlined characters
   _DrawAutoQueueLabel($aPos[0]+300, $aPos[1]+140)

   _MenuLoop($EnemyDefineForm, 1, $OK, $Control_Buttons_EnemyDefineForm)
   ;AdlibUnRegister("check")

   _Metro_GUIDelete($EnemyDefineForm) ;Delete GUI/release resources, make sure you use this when working with multiple GUIs!
   GUISetState(@SW_HIDE)

   Return ; tipota den epistrefei, apla grafei sto $search kai meta to pernei to epomeno GUIGUICreate
EndFunc

Func _DrawAutoQueueLabel($x, $y)
   If $autoQueue == "on" Then
	  GUICtrlCreateLabel("AutoQueue is on.", $x, $y)
	  GUICtrlSetColor(-1, 0xFF00E7)
   Else
	  GUICtrlCreateLabel("AutoQueue is off.", $x, $y)
	  GUICtrlSetColor(-1, 0xFF0000)
   EndIf
EndFunc

Func _CreateGUI($search)
	  Local $found = $search[0][2]
	  $found = StringReplace($found,"$","")
	  $found = StringTrimLeft($found, 1)

	  Local $sResult1 = _Excel_RangeRead($oWorkbook, Default, "A" & $found, Default, True)
	  Local $sResult2 = _Excel_RangeRead($oWorkbook, Default, "B" & $found, Default, True)
	  Local $sResult3 = _Excel_RangeRead($oWorkbook, Default, "C" & $found, Default, True)
	  _Excel_Close($oExcel, Default, True)

	  Local $runes_and_build = "None."
	  Local $summoner_spells = "None."
	  Local $starting_items = "None."

	  If _Occurence($sResult3, ".") > 3 Then
		 $split = StringSplit($sResult3, ".")
		 $runes_and_build = $split[1] & "."
		 While StringLeft($runes_and_build, 1) == " "
			$runes_and_build = StringTrimLeft($runes_and_build, 1)
		 WEnd
		 $summoner_spells = $split[2] & "."
		 While StringLeft($summoner_spells, 1) == " "
			$summoner_spells = StringTrimLeft($summoner_spells, 1)
		 WEnd
		 $starting_items = $split[3] & "."
		 While StringLeft($starting_items, 1) == " "
			$starting_items = StringTrimLeft($starting_items, 1)
		 WEnd
	  EndIf

	  $sResult3 = StringReplace($sResult3, $runes_and_build, '')
	  $sResult3 = StringReplace($sResult3, $summoner_spells, '')
	  $sResult3 = StringReplace($sResult3, $starting_items, '')
	  While StringLeft($sResult3, 1) == " "
		 $sResult3 = StringTrimLeft($sResult3, 1)
	  WEnd


		 ; Calculation of the app's height, based on how long the text/description/guide is.
		 If (StringLen($sResult3) < 125) Then
			$appHeight = StringLen($sResult3)*0.595
		 ElseIf (StringLen($sResult3) < 250) Then
			$appHeight = StringLen($sResult3)*0.545
		 ElseIf (StringLen($sResult3) < 500) Then
			$appHeight = StringLen($sResult3)*0.495
		 ElseIf (StringLen($sResult3) < 650) Then ; Amumu
			$appHeight = StringLen($sResult3)*0.5
		 ElseIf (StringLen($sResult3) < 840) Then ; Sett
			$appHeight = StringLen($sResult3)*0.485
		 ElseIf (StringLen($sResult3) < 1000) Then
			$appHeight = StringLen($sResult3)*0.435
		 ElseIf (StringLen($sResult3) < 1500) Then
			$appHeight = StringLen($sResult3)*0.395
		 ElseIf (StringLen($sResult3) < 2000) Then
			$appHeight = StringLen($sResult3)*0.345
		 ElseIf (StringLen($sResult3) < 2500) Then
			$appHeight = StringLen($sResult3)*0.295
		 ElseIf (StringLen($sResult3) < 3000) Then
			$appHeight = StringLen($sResult3)*0.275
		 EndIf

		 ; Minimum height of application
		 If $appHeight < 300 Then
			$appHeight = 300
		 EndIf

		 ; Used for DEBUG
		 ; Tooltip(StringLen($sResult3))

		 ; Calculation of the app's width
		 Local $appWidth
		 If ($runes_and_build > $summoner_spells) and ($runes_and_build > $starting_items) Then
			$appWidth = StringLen($runes_and_build)*9
		 ElseIf ($summoner_spells > $runes_and_build) and ($summoner_spells > $starting_items) Then
			$appWidth = StringLen($summoner_spells)*9
		 Else
			$appWidth = StringLen($starting_items)*9
		 EndIf

	  If $appWidth < 800 Then
		 $appWidth = 800
	  EndIf
	  if $appWidth > 800 Then
		 $appHeight = $appHeight-($appWidth/9)
	  EndIf
	  $Form1 = _Metro_CreateGUI($appName, $appWidth, $appHeight+20+25, -1, -1, False)
	  ;Add/create control buttons to the GUI
	  $Control_Buttons = _Metro_AddControlButtons(True, True, True, False, True) ;CloseBtn = True, MaximizeBtn = True, MinimizeBtn = True, FullscreenBtn = True, MenuBtn = True
	  ;Set variables for the handles of the GUI-Control buttons. (Above function always returns an array this size and in this order, no matter which buttons are selected.)
	  $GUI_CLOSE_BUTTON = $Control_Buttons[0]
	  $GUI_MAXIMIZE_BUTTON = $Control_Buttons[1]
	  $GUI_RESTORE_BUTTON = $Control_Buttons[2]
	  $GUI_MINIMIZE_BUTTON = $Control_Buttons[3]
	  $GUI_FULLSCREEN_BUTTON = $Control_Buttons[4]
	  $GUI_FSRestore_BUTTON = $Control_Buttons[5]
	  $GUI_MENU_BUTTON = $Control_Buttons[6]
	  ;GUICreate("Your enemy will be " & $sResult1 & " - " & $sResult2, $appWidth, $appHeight, Default, Default, Default, 8) ; will create a dialog box that when displayed is centered

	  $font="Open Sans"
	  GUISetFont (15, 400, 2, $font); will display underlined characters
	  Local $yourEnemyWillBe = GUICtrlCreateLabel ( "Your enemy will be " & $sResult1 & " -", 20,15+25)
	  GUICtrlSetColor(-1, $ButtonBKColor)
	  GUISetFont (13, 400, 2, $font); will display underlined characters
	  If $championSetting == "tryndamere_top" Then
		 GUICtrlCreateLabel ( @CRLF & "Runes/ Build: " & $runes_and_build & @CRLF & "Summoner Spells: " & $summoner_spells & @CRLF & "Starting Items: " & $starting_items, 30,39+23, $appWidth, 300)
	  ElseIf $championSetting == "tryndamere_mid" Then
		 GUICtrlCreateLabel ( @CRLF & "Runes/ Build: " & $runes_and_build & @CRLF & "Summoner Spells: " & $summoner_spells & @CRLF & "Starting Items: " & $starting_items, 30,39+23, $appWidth, 300)
	  ElseIf $championSetting == "shaco" Then
		 GUICtrlCreateLabel ( @CRLF & "Runes/ Build: " & $runes_and_build & @CRLF & "Summoner Spells: " & $summoner_spells & @CRLF & "Jungling Route: " & $starting_items, 30,39+23, $appWidth, 300)
	  ElseIf $championSetting == "thresh" Then
		 GUICtrlCreateLabel ( @CRLF & "Runes/ Build: " & $runes_and_build & @CRLF & "Summoner Spells: " & $summoner_spells & @CRLF & "Starting Items: " & $starting_items, 30,39+23, $appWidth, 300)
	  ElseIf $championSetting == "zyra" Then
		 GUICtrlCreateLabel ( @CRLF & "Runes/ Build: " & $runes_and_build & @CRLF & "Summoner Spells: " & $summoner_spells & @CRLF & "Starting Items: " & $starting_items, 30,39+23, $appWidth, 300)
	  EndIf
	  GUICtrlSetColor(-1, $FontThemeColor)
	  ;GUISetFont (13.2, 400, 2, $font); will display underlined characters

	  GUISetFont (15, 400, 2, $font); will display underlined characters
	  GUICtrlCreateLabel ( "Here is how you are going to play versus him/ her/ it", 20,135+25)
	  GUICtrlSetColor(-1, $ButtonBKColor)

	  GUISetFont (13, 400, 2, $font); will display underlined characters
	  GUICtrlCreateLabel ( @CRLF & $sResult3, 30,160+25, $appWidth-50, $appHeight-50+20)
	  GUICtrlSetColor(-1, $FontThemeColor)

	  GUISetState(@SW_SHOW)

	  Local $aPos = ControlGetPos("", "", $Form1)
	  GUISetFont (12, 400, 2, $font); will display underlined characters
	  _DrawAutoQueueLabel($appWidth-130, $appHeight+20)

	  Local $aPos = ControlGetPos("", "", $yourEnemyWillBe)
	  GUISetFont (15, 400, 2, $font); will display underlined characters
	  $difficulty = GUICtrlCreateLabel ($sResult2,$aPos[0]+$aPos[2],15+25)
	  If ($sResult2 == "Very Easy") Then
		 GUICtrlSetColor(-1, 0x00FF00)
	  ElseIf ($sResult2 == "Easy") Then
		 GUICtrlSetColor(-1, 0x66CC00)
	  ElseIf ($sResult2 == "Medium") Then
		 GUICtrlSetColor(-1, 0xE3FF00)
	  ElseIf ($sResult2 == "Hard") Then
		 GUICtrlSetColor(-1, 0xFF0000)
	  ElseIf ($sResult2 == "Very Hard") Then
		 GUICtrlSetColor(-1, 0xB30000)
	  Else
		 GUICtrlSetColor(-1, 0xFF00E7)
	  EndIf
	  Local $aPos = ControlGetPos("", "", $difficulty)
	  Local $ChangeChampion = _Metro_CreateButtonEx2("Change Enemy", $aPos[0]+$aPos[2]+5, $aPos[1]-3.2, 120, 30)

	  _MenuLoop($Form1, 0, $ChangeChampion, $Control_Buttons)
EndFunc

Func _Occurence($s_text, $s_char)
    Return UBound(StringSplit($s_text, $s_char))-2
EndFunc  ;==>_Occurence