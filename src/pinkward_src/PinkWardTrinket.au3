#RequireAdmin
#include "_ImageSearch_UDF.au3"
#include "_ImageSearch_Tool.au3"


Global $_Image_00 = @ScriptDir & "\pinkward_first.bmp"
Global $_Image_01 = @ScriptDir & "\pinkward_second.bmp"
Global $_Image_02 = @ScriptDir & "\trinket_upgrade.bmp"
Global $_Image_03 = @ScriptDir & "\shop_is_open.bmp"
Global $_Image_04 = @ScriptDir & "\tryndamere_dead.bmp"
Global $hasOnePinkward = @ScriptDir & "\hasOne.bmp"
Global $hasUpgradedTrinket = @ScriptDir & "\hasUpgrade.bmp"
Global Const $tol = 75
Global Const $tol2 = 90


Func _BuyPinkWard()
   Local $pinkward_first[3]
   Local $pinkward_second[3]
   Local $has_one_pinkward[3]

   Local $trinket_upgrade[3]
   Local $has_upgrade[3]


   Local $shop_is_open[3]
   Local $tryndamere_dead[3]

   $tryndamere_dead =_ImageSearch($_Image_04, $tol2, true)
   If $tryndamere_dead[0] == 1 Then
	  ; Spam
	  $has_one_pink = _ImageSearch($hasOnePinkward, $tol, true)
	  If $has_one_pink[0] == 1 Then
		Send("{ALTDOWN}")
		_Click($has_one_pink[1], $has_one_pink[2]) ; Click Inventory Pinkward
		Send("{ALTUP}")
		_Click($tryndamere_dead[1], $tryndamere_dead[2]) ; Click Inventory Pinkward
		Sleep(Random(1000, 1500)
	 EndIf
   EndIf


   $shop_is_open = _ImageSearch($_Image_03, $tol2, true)
   If $shop_is_open[0] == 1 Then
			   $has_upgrade = _ImageSearch($hasUpgradedTrinket, $tol, true)
			   If $has_upgrade[0] == 0 Then
					 $trinket_upgrade = _ImageSearch($_Image_02, $tol, true)
					 If $trinket_upgrade[0] == 1 Then
						_Click($trinket_upgrade[1], $trinket_upgrade[2]) ; OK
						_Click($trinket_upgrade[1], $trinket_upgrade[2]) ; OK
					 EndIf
			   EndIf

			   $has_one_pinkward = _ImageSearch($hasOnePinkward, $tol, true)

			   If $has_one_pinkward[0] == 0 Then ; Buy one to make it == 1
				  $pinkward_first = _ImageSearch($_Image_00, $tol, true)
				  $pinkward_second = _ImageSearch($_Image_01, $tol, true)
				  If $pinkward_first[0] == 1 Then ; Shop is open
					 _Click($pinkward_first[1], $pinkward_first[2]) ; OK
					 _Click($pinkward_first[1], $pinkward_first[2]) ; OK
				  ElseIf $pinkward_second[0] == 1 Then ; Shop is open
					 _Click($pinkward_second[1], $pinkward_second[2]) ; OK
					 _Click($pinkward_second[1], $pinkward_second[2]) ; OK
				  EndIf
			   EndIf

			   While $shop_is_open[0] == 1
				  $shop_is_open = _ImageSearch($_Image_03, $tol2, true)
			   WEnd
   EndIf
EndFunc

Func _Click($x, $y)
   _Move($x, $y)
   Sleep(50)
   MouseClick("left", $x, $y, 1)
EndFunc

Func _Move($x, $y)
   MouseMove($x, $y, 0)
EndFunc

While 1
   _BuyPinkWard()
WEnd
