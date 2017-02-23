#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=gui\app.ico
#AutoIt3Wrapper_Res_Description=Delay Start App
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=(c) JythmDev
#AutoIt3Wrapper_Res_Language=1036
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#RequireAdmin
#include<GuiListView.au3>
#include<GuiEdit.au3>
#include<File.au3>
#include<GuiButton.au3>
#include<WindowsConstants.au3>
#include<Process.au3>

$solo = ProcessList(@ScriptName)
If $solo[0][0] > 1 Then Exit

$file_config = @ScriptDir & "\bdd\config.ini"
$select_lng = IniRead($file_config,"config","lng","en")
$_LGN_ = IniReadSection(@ScriptDir & "\lng\" & $select_lng & ".lng","lng")

Opt("GuiCloseOnESC",0)
Opt("GUIOnEventMode",1)
Opt("TrayMenuMode",1)
Opt("TrayOnEventMode",1)

$autorun = 0
If $CmdLine[0] > 0 then
	$autorun = 1
EndIf

Global $gui_cell,$edit_cell,$Item = -1,$SubItem = 0

$file_bdd = @ScriptDir & "\bdd\bdd.txt"
$dir_gui = @ScriptDir & "\gui\"

$tray_state = 0
$lock = 0
$guiname = "DStartApp"
$gui = GUICreate($guiname,600,400,-1,-1,0x80000000)
	GUISetBkColor(0xffffff)

TraySetToolTip($guiname)

$titre = GUICtrlCreateLabel($guiname,10,0,130,25,0x01)
	GUICtrlSetColor(-1,0xffffff)
	GUICtrlSetBkColor(-1,0x000000)
	GUICtrlSetFont(-1,15)
	GUICtrlSetOnEvent(-1,"_Menu_")

$menu_titre = GUICtrlCreateContextMenu($titre)
	GUICtrlCreateMenuItem($_LGN_[1][1],$menu_titre)
		GUICtrlSetOnEvent(-1,"_Quitter_")

GUICtrlCreateLabel("",140,0,310,35,-1,0x00100000)
	GUICtrlSetBkColor(-1,-2)


$list_lng = _FileListToArray(@ScriptDir & "\lng","*.lng",1)
$combo_lng = ""
For $lng = 1 To $list_lng[0]
	If $select_lng & ".lng" <> $list_lng[$lng] Then $combo_lng = $combo_lng & $list_lng[$lng] & "|"
Next
$combo_lng = StringReplace($combo_lng,".lng","")
$combo_lng_gui = GUICtrlCreateCombo($select_lng,450,1,70,25,BitOR(0x0003,0x00200000))
	GUICtrlSetData(-1,$combo_lng)
	GUICtrlSetOnEvent(-1,"_ChangeLNG_")
	GUICtrlSetFont(-1,11)




GUICtrlCreateLabel("_",535,0,25,25,0x01)
	GUICtrlSetColor(-1,0xffffff)
	GUICtrlSetBkColor(-1,0x000000)
	GUICtrlSetFont(-1,15)
	GUICtrlSetOnEvent(-1,"_Reduire_")
GUICtrlCreateLabel("X",565,0,25,25,0x01)
	GUICtrlSetColor(-1,0xffffff)
	GUICtrlSetBkColor(-1,0x000000)
	GUICtrlSetFont(-1,15)
	GUICtrlSetOnEvent(-1,"_Quitter_")

GUICtrlCreateGraphic(0,0,600,1)
GUICtrlSetColor(-1,0x000000)
GUICtrlCreateGraphic(0,399,600,1)
GUICtrlSetColor(-1,0x000000)
GUICtrlCreateGraphic(0,0,1,399)
GUICtrlSetColor(-1,0x000000)
GUICtrlCreateGraphic(599,0,1,399)
GUICtrlSetColor(-1,0x000000)

GUICtrlCreateGroup("",5,30,590,55)
	GUICtrlCreateButton("",10,40,40,40,0x0040)
		_GUICtrlButton_SetImage(-1,$dir_gui & "add.ico")
		GUICtrlSetOnEvent(-1,"_Add_")
		GUICtrlSetTip(-1,$_LGN_[2][1])
	GUICtrlCreateButton("",50,40,40,40,0x0040)
		_GUICtrlButton_SetImage(-1,$dir_gui & "del.ico")
		GUICtrlSetOnEvent(-1,"_Del_")
		GUICtrlSetTip(-1,$_LGN_[3][1])
	$load = GUICtrlCreateButton("",550,40,40,40,0x0040)
		_GUICtrlButton_SetImage(-1,$dir_gui & "load.ico")
		GUICtrlSetOnEvent(-1,"_Load_")

$list = _GUICtrlListView_Create($gui,$_LGN_[4][1] & "|" & $_LGN_[5][1] & "|" & $_LGN_[6][1],5,95,590,300,BitOR(0x0001,0x00200000,0x0004),0x00000200)
	_GUICtrlListView_SetExtendedListViewStyle($list,$LVS_EX_GRIDLINES)
	ControlDisable($guiname,"",HWnd(_GUICtrlListView_GetHeader($list)))

GUIRegisterMsg($WM_NOTIFY,"WM_NOTIFY")

_RefreshList_()

_GUICtrlListView_SetColumnWidth($list,0,300)
_GUICtrlListView_SetColumnWidth($list,1,150)
_GUICtrlListView_SetColumnWidth($list,2,100)



If IniRead($file_config,"config","autorun","") == 0 Then
	_GUICtrlButton_SetImage($load,$dir_gui & "off.ico")
	GUICtrlSetTip($load,$_LGN_[7][1])
Else
	_GUICtrlButton_SetImage($load,$dir_gui & "on.ico")
	GUICtrlSetTip($load,$_LGN_[8][1])
EndIf


If $autorun == 1 Then
	_AutoRun_()
Else
	GUISetState()
EndIf

While 1
	Sleep(100)
WEnd

Func _Quitter_()
	_AutoSave_()
	Exit
EndFunc

Func _QuitterT_()
	Exit
EndFunc

Func _Reduire_()
	GUISetState(@SW_MINIMIZE)
EndFunc

Func _Menu_()
	MouseClick("right")
EndFunc


Func _Add_()
	$msgb = FileOpenDialog($_LGN_[4][1],@DesktopDir,$_LGN_[4][1] & " (*.exe;*.cmd;*.bat)",1,"",$gui)
	If Not @error Then
		_GUICtrlListView_AddItem($list,$msgb)
		_GUICtrlListView_AddSubItem($list,_GUICtrlListView_GetItemCount($list) - 1,"",1)
		_GUICtrlListView_AddSubItem($list,_GUICtrlListView_GetItemCount($list) - 1,"60",2)
		_GUICtrlListView_Scroll($list,0,50000)
		_AutoSave_()
	EndIf
EndFunc

Func _Del_()
	$select = _GUICtrlListView_GetItemText($list,_GUICtrlListView_GetSelectionMark($list),2)
	If $select <> "" Then
		_GUICtrlListView_DeleteItem($list,_GUICtrlListView_GetSelectionMark($list))
		_AutoSave_()
	EndIf
EndFunc

Func _AutoSave_()
	$maxt = 0
	$open = FileOpen($file_bdd,2)
	For $i1 = 1 To _GUICtrlListView_GetItemCount($list)
		$0 = _GUICtrlListView_GetItemText($list,$i1 - 1,0)
		$1 = _GUICtrlListView_GetItemText($list,$i1 - 1,1)
		$2 = _GUICtrlListView_GetItemText($list,$i1 - 1,2)
		FileWrite($open,$0 & "|" & $1 & "|" & $2 & @CRLF)
		If $maxt < Ceiling($2) Then
			$maxt = $2
		EndIf
	Next
	FileClose($open)
	IniWrite($file_config,"config","stop",$maxt)
	_GUICtrlListView_SetColumnWidth($list,0,300)
	_GUICtrlListView_SetColumnWidth($list,1,150)
	_GUICtrlListView_SetColumnWidth($list,2,100)
EndFunc

Func _RefreshList_()
	ControlHide($guiname,"",$list)
	_GUICtrlListView_DeleteAllItems($list)
	$nbr_file = _FileCountLines($file_bdd)
	$open = FileOpen($file_bdd,0)
	For $i1 = 1 To $nbr_file
		$read = FileReadLine($open,$i1)
		$bdd_split = StringSplit($read,"|")
		If Not @error Then
			_GUICtrlListView_AddItem($list,$bdd_split[1])
			_GUICtrlListView_AddSubItem($list,$i1 - 1,$bdd_split[2],1)
			_GUICtrlListView_AddSubItem($list,$i1 - 1,$bdd_split[3],2)
		EndIf
	Next
	FileClose($open)
	ControlShow($guiname,"",$list)
EndFunc

Func _Load_()
	If IniRead($file_config,"config","autorun","") == 0 Then
		_GUICtrlButton_SetImage($load,$dir_gui & "on.ico")
		GUICtrlSetTip($load,"Clic pour activer")
		IniWrite($file_config,"config","autorun","1")
		_RunDos('schtasks /create /sc ONLOGON /tn DStart /tr "' & @ScriptFullPath & ' -go" /rl highest')
	Else
		_GUICtrlButton_SetImage($load,$dir_gui & "off.ico")
		GUICtrlSetTip($load,"Clic pour désactiver")
		IniWrite($file_config,"config","autorun","0")
		_RunDos('schtasks /delete /tn DStart /f')
	EndIf
EndFunc

Func _AutoRun_()
	TrayCreateItem("Arrêter et quitter")
		TrayItemSetOnEvent(-1,"_QuitterT_")
	ControlHide($guiname,"",$gui)
	Global $time = 0
	Global $max_time = IniRead($file_config,"config","stop","")
	AdlibRegister("_Time_",1000)
EndFunc

Func _Time_()
	TraySetToolTip($guiname & " T=" & $time & "/" & $max_time)
	$nbr_file = _FileCountLines($file_bdd)
	$open = FileOpen($file_bdd,0)
	For $i1 = 1 To $nbr_file
		$read = FileReadLine($open,$i1)
		$bdd_split = StringSplit($read,"|")
		If Not @error Then
			If $bdd_split[3] == $time Then
				ShellExecute($bdd_split[1],$bdd_split[2])
			EndIf
		EndIf
	Next
	FileClose($open)
	$time = $time + 1
	If $time > $max_time Then Exit
EndFunc

Func WM_NOTIFY($hWnd,$iMsg,$iwParam,$ilParam)
    Local $tNMHDR,$hWndFrom,$iCode
    $tNMHDR = DllStructCreate($tagNMHDR,$ilParam)
    $hWndFrom = DllStructGetData($tNMHDR,"hWndFrom")
    $iCode = DllStructGetData($tNMHDR,"Code")
    Switch $hWndFrom
        Case $list
            Switch $iCode
                Case $NM_DBLCLK
                    Local $aHit = _GUICtrlListView_SubItemHitTest($list)
					Global $enter = $aHit
					If $lock == 0 Then
						If ($aHit[0] <> -1) And ($aHit[1] < 3) Then
							HotKeySet("{ENTER}","_Cell_Validate_")
							$Item = $aHit[0]
							$SubItem = $aHit[1]
							Local $iSubItemText = _GUICtrlListView_GetItemText($list,$Item,$SubItem)
							Local $aRect = _GUICtrlListView_GetSubItemRect($list,$Item,$SubItem)
							$WinGetPos = WinGetPos($guiname)
							$gui_cell = GUICreate("cell",$aRect[2] - $aRect[0] - 4,18,$WinGetPos[0] + $aRect[0] + 7,$WinGetPos[1] + $aRect[1] + 96,0x80000000,0x00000200,$gui)
							If $aHit[1] == 1 Then
								$edit_cell = GUICtrlCreateInput($iSubItemText,0,0,$aRect[2] - $aRect[0],20)
							ElseIf $aHit[1] == 2 Then
								$edit_cell = GUICtrlCreateCombo("",0,0,$aRect[2] - $aRect[0],20,BitOR(0x0003,0x00200000))
								GUICtrlSetData(-1,"60|120|180|240|300|600|1800|3600",$iSubItemText)
							EndIf
							GUISetState()
							_WinAPI_SetFocus($edit_cell)
							$lock = 1
							AdlibRegister("_Cell_Save_",250)
						EndIf
					EndIf
			EndSwitch
    EndSwitch
EndFunc

Func _Cell_Save_()
	If ControlGetFocus("cell") <> "Edit1" And ControlGetFocus("cell") <> "ComboBox1" Then
		AdlibUnRegister("_Cell_Save_")
		_GUICtrlListView_SetItemText($list,$Item,GUICtrlRead($edit_cell),$SubItem)
		$Item = -1
		$SubItem = 0
		_AutoSave_()
		GUIDelete($gui_cell)
		$lock = 0
	EndIf
EndFunc

Func _Cell_Validate_()
	_GUICtrlListView_ClickItem($list,$enter[0])
	HotKeySet("{ENTER}")
EndFunc

Func _ChangeLNG_()
	If GUICtrlRead($combo_lng_gui) <> $select_lng Then
		IniWrite($file_config,"config","lng",GUICtrlRead($combo_lng_gui))
		MsgBox(0,"- " & $_LGN_[9][1] & " -",$_LGN_[10][1],0,$gui)
	EndIf
EndFunc



