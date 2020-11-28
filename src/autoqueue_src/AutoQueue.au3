#RequireAdmin
#include "_ImageSearch_UDF.au3"
#include "_ImageSearch_Tool.au3"

$scriptDir = @ScriptDir
Global $autoQueueFile = StringLeft($scriptDir,StringInStr($scriptDir,"\",0,-1)-1) & "\autoQueueSetting.txt"
Global $championSettingFile = StringLeft($scriptDir,StringInStr($scriptDir,"\",0,-1)-1) & "\championSetting.txt"
Global $cancel_coords[2]
Global $re_start_coords[2]
Global $_Image_00 = @ScriptDir & "\top.bmp"
Global $_Image_01 = @ScriptDir & "\mid.bmp"
Global $_Image_02 = @ScriptDir & "\support.bmp"
Global $_Image_03 = @ScriptDir & "\jungle.bmp"
Global $_Image_2 = @ScriptDir & "\decline.bmp"
Global $_Image_3 = @ScriptDir & "\ranked_solo_duo.bmp"
Global $_Image_4 = @ScriptDir & "\cancel.bmp"

Global $tol = 0
Global $autoQueue = FileReadLine($autoQueueFile, 1); on_tryndamere_top on_thresh
Global $autoQueueSeconds = Int(FileReadLine($autoQueueFile, 2)) ; seconds
;50 se top_lane_first
;180 se time_passed


;$waitreturn
;1 -> Time limit reached
;2 -> Alt-Tab pressed ---> First because the
;3 -> Queue interrupted by user
;-1 -> Match Accepted or Declined
Global $wait_return

Global $coords[4]
Global $cancel_coords[2]
Global $re_start_coords[2]
Global $choose_roles = 1

Func _CheckForSoloDuoQueueLobby($more_tol = 0)
   ;ToolTip("Searching for 'ranked_solo_duo2.bmp'. Tolerance: " & $tol+$more_tol)
   Local $ranked_solo_duo = _ImageSearchArea($_Image_3, $coords[0], $coords[1], $coords[2], $coords[3], $tol+$more_tol, True)
   Return $ranked_solo_duo[0]
EndFunc

Func _CheckForFirstRoleTop()
   ;ToolTip("Searching for 'init.bmp'.")
   Local $init = _ImageSearchArea($_Image_00, $coords[0], $coords[1], $coords[2], $coords[3], $tol, True)
   Return $init[0]
EndFunc

Func _CheckForFirstRoleMid()
   ;ToolTip("Searching for 'init.bmp'.")
   Local $init = _ImageSearchArea($_Image_01, $coords[0], $coords[1], $coords[2], $coords[3], $tol, True)
   Return $init[0]
EndFunc

Func _CheckForFirstRoleSupport()
   ;ToolTip("Searching for 'init.bmp'.")
   Local $init = _ImageSearchArea($_Image_02, $coords[0], $coords[1], $coords[2], $coords[3], $tol, True)
   Return $init[0]
EndFunc

Func _CheckForFirstRoleJungle()
   ;ToolTip("Searching for 'init.bmp'.")
   Local $init = _ImageSearchArea($_Image_03, $coords[0], $coords[1], $coords[2], $coords[3], $tol, True)
   Return $init[0]
EndFunc

Func _CheckClickBanOK()
	  $ban_ok = _ImageSearchArea($_Image_4, $coords[0], $coords[1], $coords[2], $coords[3], $tol+10, True)
	  If $ban_ok[0] == 1 Then
			Sleep(1000)
			_Click($ban_ok[1], $ban_ok[2]) ; OK
			_Click($ban_ok[1], $ban_ok[2]) ; OK
			Return 1
	  EndIf
	  Return 0
EndFunc

Func _Init()
   While WinExists("League of Legends") == 0
   WEnd
   WinWaitActive("League of Legends")
   $coords = WinGetPos("League of Legends")
   $cancel_coords[0] = $coords[0]+557
   $cancel_coords[1] = $coords[1]+854
   $re_start_coords[0] = $cancel_coords[0]+113
   $re_start_coords[1] = $cancel_coords[1]
EndFunc

Global $force_decline = 0
While 1
   _Init()

   While _CheckForSoloDuoQueueLobby(10) == 0 and _CheckForSoloDuoQueueLobby() == 0
	  _CheckClickBanOK()
	  If $force_decline == 1 Then
		 ;;ToolTip("You are in different menu, the next game will be declined, or if you get in lobby, I will cancel it.")
		 $accept_decline = _CheckForAcceptDeclineButtons()
		 If $accept_decline[0] == 1 Then
			_Click($accept_decline[1], $accept_decline[2]+370) ; Decline
		 EndIf
	  EndIf
   WEnd

   if $force_decline == 1 and _CheckForFirstRoleTop() == 0 and _CheckForFirstRoleMid() == 0 and _CheckForFirstRoleSupport() == 0 and _CheckForFirstRoleJungle() == 0 Then
	  _Click($cancel_coords[0], $cancel_coords[1])
   EndIf
   $force_decline = 0

   While ($coords[2] <> 1600 and $coords[3] <> 900)
	  $coords = WinGetPos("League of Legends")
	  ;ToolTip("Please change the client resolution to 1600x900.")
   WEnd

   $autoQueue = FileReadLine($autoQueueFile, 1)
   If $autoQueue == "on" Then
	  $championSelected = FileReadLine($championSettingFile, 1)
	  Switch $championSelected
		 Case "tryndamere_top"
			While _CheckForFirstRoleTop() == 0
			WEnd
		 Case "tryndamere_mid"
			While _CheckForFirstRoleMid() == 0
			WEnd
		 Case "thresh"
			While _CheckForFirstRoleSupport() == 0
			WEnd
		 Case "zyra"
			While _CheckForFirstRoleSupport() == 0
			WEnd
		 Case "shaco"
			While _CheckForFirstRoleJungle() == 0
			WEnd
		 EndSwitch
   Else
	  Exit
   EndIf

   If $choose_roles == 1 Then
	  $choose_roles = 0
	  ; Vazei deutero role kai to dinei
	  if _CheckForFirstRoleMid() == 1 Then
		 _Click($re_start_coords[0]+50, $re_start_coords[1]-250)
		 _Click($re_start_coords[0]+50-100, $re_start_coords[1]-250)
	  Else
		 _Click($re_start_coords[0]+50, $re_start_coords[1]-250)
		 _Click($re_start_coords[0]+50, $re_start_coords[1]-250-100)
	  EndIf
   EndIf
   _Click($re_start_coords[0], $re_start_coords[1])
	_Move($cancel_coords[0], $cancel_coords[1])

   ; Perimenei
   $local = _Wait()
   While $local <> -1 ; -1 ksefeugei apo to loop
	  Switch $local
	  Case 1
			If _CheckForSoloDuoQueueLobby(10) == 1 Then
			   _Click($cancel_coords[0], $cancel_coords[1])
			Else
			   $force_decline = 1
			EndIf
			;;ToolTip("Stopped by AutoQueue")
			$local = -1
		 Case 2 ; alt-tab
			WinWaitActive("League of Legends")
			If _CheckForSoloDuoQueueLobby(10) == 1 Then
			   _Click($cancel_coords[0], $cancel_coords[1])
			EndIf
			$local = -1 ; Epanakinei
		 Case 3 ; Stopped by user
			;;ToolTip("Stopped by user")
			; Perimenw na to ksana arxisei monos toy
			_WaitUntilHeStartsQueue()
			;;ToolTip("Started by user")
			$local = _Wait()
	  EndSwitch
   WEnd
WEnd

Func _Wait()
	  Sleep(500) ; Mikro dialima gia na eksafanistei to $init

	  $new_wait_return = $wait_return
	  Local $hTimer = TimerInit() ; Begin the timer and store the handle in a variable.
	  Local $init
	  While 1
			If _CheckClickBanOK() == 1 Then
			   $new_wait_return = -1
			   ExitLoop
			EndIf

			$championSelected = FileReadLine($championSettingFile, 1)
			Switch $championSelected
			   Case "tryndamere_top"
				  $init = _ImageSearchArea($_Image_00, $coords[0], $coords[1], $coords[2], $coords[3], $tol, True)
			   Case "tryndamere_mid"
				  $init = _ImageSearchArea($_Image_01, $coords[0], $coords[1], $coords[2], $coords[3], $tol, True)
			   Case "thresh"
				  $init = _ImageSearchArea($_Image_02, $coords[0], $coords[1], $coords[2], $coords[3], $tol, True)
			   Case "zyra"
				  $init = _ImageSearchArea($_Image_02, $coords[0], $coords[1], $coords[2], $coords[3], $tol, True)
			   Case "shaco"
				  $init = _ImageSearchArea($_Image_03, $coords[0], $coords[1], $coords[2], $coords[3], $tol, True)
			EndSwitch

			$accept_decline = _CheckForAcceptDeclineButtons()
			Local $fDiffSeconds = TimerDiff($hTimer)/1000
			If WinActive("League of Legends") == 0 Then ; Alt-Tab
			   $new_wait_return = 2
			   ExitLoop
			ElseIf $accept_decline[0] == 1 Then ; Match found
			   If $fDiffSeconds <= $autoQueueSeconds-0.5 Then
				  _Click($accept_decline[1], $accept_decline[2]+300) ; Accept

				  $new_wait_return = -1
				  ExitLoop
			   Else
				  _Click($accept_decline[1], $accept_decline[2]+370) ; Decline
				  $new_wait_return = -1
				  ExitLoop
			   EndIf

				Send("{ALT DOWN}")
				Send("{TAB}")
				Send("{ALT UP}")
			ElseIf $init[0] == 1 Then ; Stopped by user
			   $new_wait_return = 3
			   ExitLoop
			ElseIf $fDiffSeconds > $autoQueueSeconds Then
			   $new_wait_return = 1
			   ExitLoop
			EndIf
		 WEnd

	  $wait_return = $new_wait_return
	  Return $new_wait_return
EndFunc


Func _WaitUntilHeStartsQueue()
   $autoQueue = FileReadLine($autoQueueFile, 1)
   If $autoQueue == "on" Then
	  $championSelected = FileReadLine($championSettingFile, 1)
	  Switch $championSelected
		 Case "tryndamere_top"
			While _CheckForFirstRoleTop() == 1
			WEnd
		 Case "tryndamere_mid"
			While _CheckForFirstRoleMid() == 1
			WEnd
		 Case "thresh"
			While _CheckForFirstRoleSupport() == 1
			WEnd
		 Case "zyra"
			While _CheckForFirstRoleSupport() == 1
			WEnd
		 Case "shaco"
			While _CheckForFirstRoleJungle() == 1
			WEnd
		 EndSwitch
   Else
	  Exit
   EndIf
EndFunc

Func _CheckForAcceptDeclineButtons()
   $local = _ImageSearchArea($_Image_2, $coords[0], $coords[1], $coords[2], $coords[3], $tol+10, True)
   return $local
EndFunc

Func _ImageSearchArea($image, $coords1, $coords2, $coords3, $coords4, $tol, $center)
   WinWaitActive("League of Legends")
   WinMove ( "League of Legends", Default, $coords1, $coords1 ,$coords2 , $coords3 , 0)
   Return _ImageSearch_Area($image, $coords1, $coords2, $coords3, $coords4, $tol, $center)
EndFunc

Func _Click($x, $y)
   _Move($x, $y)
   Sleep(250)
   MouseClick("left", $x, $y, 1)
EndFunc

Func _Move($x, $y)
   MouseMove($x, $y, 1)
EndFunc


