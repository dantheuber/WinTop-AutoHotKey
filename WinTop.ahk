WinTop := New AutoCreate ; create array for window hwnd and status's
SetTitleMatchMode, 2
#SingleInstance force ; force only one to be running
#NoEnv ; for compatibility
Menu, WinTop, Add, Clear Window Settings, ClearWinTopSettings					; create menu item
return

ClearWinTopSettings: ; to clear right clicked item in gui
	RegexMatch(WinTopView,"\t{4}(?<hwnd>\d+)$",_)
	WinSet, AlwaysOnTop, Off, ahk_id %hwnd%
	WinSet, Transparent, 255, ahk_id %hwnd%
	WinSet, ExStyle, -0x20, ahk_id %hwnd%
	WinTop[hwnd].AoT := AoT_Status := 0
	WinTop[hwnd].CT := CT_Status := 0
	TrayTip, WinTop, '%_title%' has been returned to default.,1,1
	goto, ReDrawWinTop		; go to redraw the gui to reflect changes
Return

50GuiContextMenu: ; context menu code
	If ( A_GuiEvent = "Normal" OR A_GuiEvent = "F" )
		Return
	If ( A_GuiControl = "WinTopView") {
		MouseClick, Left
		Gui, 50:Submit, NoHide
		If ( InStr(WinTopView,"(Title|====)") ); - only show menu if you right click on appropriate line
			Return
		Menu, WinTop, Show, %A_GuiX%, %A_GuiY%
	}
Return


; show the wintop 'viewer' window
ReDrawWinTop:
!Left::
!Right::																		; draw the wintop viewer to allow you to clear windows of style changes
	IfWinExist, WinTop Viewer
		Gui, 50:Destroy 														; destroy the gui if it is already drawn, as we are going to re-create it each time its shown
	Gui, 50:Add, ListBox, -Multi -WantF2 h360 w400 vWinTopView
	WinTopList := "|#`tOn Top`tClick-Thru`tTitle|=====================================================================================================================================================================================================================|"
	, c := 0
	for key, value in WinTop 													; loop to create list of items in array
	{
		c++
		, WinTopList .= c "`t" WinTop[key].AoT "`t" WinTop[key].CT "`t`t" WinTop[key].Title "`t`t`t`t" key "|"
		;msgbox % "key: " key "`nTitle: " WinTop[key].Title "`nAoT: " WinTop[key].AoT "`nCT: " WinTop[key].CT
	}
	GuiControl, 50:, WinTopView, %WinTopList%
	Gui, 50:Show, Center, WinTop Viewer
	Gui, 50:+AlwaysOnTop
Return

50GuiEscape:
50GuiClose:
	Gui, 50:Destroy
Return

!Up::																			  ; toggle always on top functionality of current window
	WinGet, hwnd, ID, A
	WinGetTitle, title, A
	If ( title = "WinTop Viewer" )						; if current window is the app gui itself, do not do anything
		Return
	temp := WinTop[hwnd].title
	If ( temp != title ) {										; if the current title was not found then set defaults
		WinTop[hwnd].Title := Title, WinTop[hwnd].AoT := WinTop[hwnd].CT := 0
	} Else {																	; else get status's for hwnd from array
		AoT_Status := WinTop[hwnd].AoT, CT_Status := WinTop[hwnd].CT, WinTop[hwnd].Title := Title
	}
	If ( AoT_Status = 0 ) {										; if it is not always on top currently
		WinSet, AlwaysOnTop, On, ahk_id %hwnd%	; set it to always on top
		WinTop[hwnd].AoT := AoT_Status := 1
	} Else If ( AoT_Status ) {								; else it is already always on top
		WinSet, AlwaysOnTop, Off, ahk_id %hwnd%
		WinTop[hwnd].AoT := AoT_Status := 0 		; so turn it off
	} Else { 																	; otherwise, it was not in the array so we'll turn it on and set the array
		WinSet, AlwaysOnTop, On, ahk_id %hwnd%
		WinTop[hwnd].AoT := AoT_Status := 1
	}
	If ( AoT_Status )													; display new status of window
		TrayTip, WinTop, %title% is now always on top!,1,1
	Else TrayTip, WinTop, %title% is no longer on top!,1,1
	AoT_Status := "", CT_Status := ""
Return

!Down::																			; toggle click-through of window -- NOTE: this also turns on and off always on top / transparency with it
	WinGetActiveTitle, title 									; because if you're enabling clickthru you are going to want it on top... right?
 	WinGet, hwnd, ID, A
	If ( t = "WinTop Viewer")									; if current window is the viewer gui don't do anything
		Return
	temp := WinTop[hwnd].Title
	If ( temp != title ) {										; if the current window is not in the db then we'll add it
		WinTop[hwnd].Title := Title, WinTop[hwnd].AoT := WinTop[hwnd].CT := 0
	} Else {																	; else get the current info from the db
		AoT_Status := WinTop[hwnd].AoT, CT_Status := WinTop[hwnd].CT, WinTop[hwnd].title := Title
	}
	If ( CT_Status = 0 ) {										; if clickthru is off then lets turn it and Always on top on
		WinSet, AlwaysOnTop, On, ahk_id %hwnd%
		WinSet, Transparent, 125, ahk_id %hwnd%
		WinSet, ExStyle, +0x20, ahk_id %hwnd%
		WinTop[hwnd].AoT := AoT_Status := 1
		WinTop[hwnd].CT := CT_Status := 1
	} Else If ( CT_Status = 1 ) {							; else lets turn that shut off
		WinSet, AlwaysOnTop, Off, ahk_id %hwnd%	; -- this will eventually remember the prior status of always on top and retain it
		WinSet, Transparent, 255, ahk_id %hwnd%
		WinSet, ExStyle, -0x20, ahk_id %hwnd%
		WinTop[hwnd].AoT := AoT_Status := 0
		WinTop[hwnd].CT := CT_Status := 0
	} Else { 																	; else it was not found in the db and we need to set it all on
		WinSet, AlwaysOnTop, On, ahk_id %hwnd%
		WinSet, Transparent, 125, ahk_id %hwnd%
		WinSet, ExStyle, +0x20, ahk_id %hwnd%
		WinTop[hwnd].AoT := AoT_Status := 1
		WinTop[hwnd].CT := CT_Status := 1
	}
	If ( CT_Status )													; notify of the new window status
		TrayTip, WinTop, %t% is now clickthru!,1,1
	Else TrayTip, WinTop, %t% is no longer clickthru!,1,1
	CT_Status := "", AoT_Status := ""
Return

class AutoCreate {
   __Get(key) {
	  if (key != "base")
	     this[key] := new this.base
   }
}
