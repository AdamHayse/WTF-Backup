__wow_dir := "C:\Program Files (x86)\World of Warcraft"
class WindowEvents {
  static _nextId := 0

  static HSHELL_RUDEAPPACTIVATED  := 0x8004
  static HSHELL_WINDOWACTIVATED := 4
  static HSHELL_WINDOWREPLACED := 13
  static HSHELL_WINDOWCREATED := 1
  static HSHELL_WINDOWDESTROYED := 2

  __new(onMessage) {
    this._onMessage := onMessage
    this._enabled := false
    this._hwnd := 0
    this._msgNum := 0
    this._guiName := "WindowEvents_" . WindowEvents._nextId
    WindowEvents._nextId := WindowEvents._nextId + 1
  }

  enable() {
    if (this._enabled) {
      return
    }

    if (!this._onMessage) {
      msgBox, % "this._onMessage not set!"
      return
    }

    gui, % this._guiName . ":New", +hwndhwnd
    this._hwnd := hwnd

    dllCall("RegisterShellHookWindow", UInt, this._hwnd)

    this._msgNum := dllCall("RegisterWindowMessage", Str, "SHELLHOOK")
    onMessage(this._msgNum, this._onMessage)

    this._enabled := true
  }

  disable() {
    if (not this._enabled) {
      return
    }

    dllCall("DeregisterShellHookWindow", UInt, this._hwnd)
    gui, % this._guiName . ":Destroy"

    this._enabled := false
  }
}

class App {

  __new() {
    this._handleMessage := ObjBindMethod(this, "_handleMessageBase")
    this._windowEvents := new WindowEvents(this._handleMessage)
    this._wowHwnds := {}
  }

  _handleMessageBase(msgType, hwnd) {
    if (msgType == WindowEvents.HSHELL_WINDOWACTIVATED
    or  msgType == WindowEvents.HSHELL_RUDEAPPACTIVATED) {
      this._handleWindowActivate(hwnd)
    }

    else if (msgType == WindowEvents.HSHELL_WINDOWDESTROYED) {
      this._handleWindowDestroy(hwnd)
    }
  }

  _handleWindowActivate(hwnd) {
    if (this._isWowHwnd(hwnd)) {
      this._wowHwnds[hwnd] := true
    }
  }

  _handleWindowDestroy(hwnd) {
    if (this._wowHwnds[hwnd]) {
      this._wowHwnds[hwnd] := false
      this._onWowWindowClose(hwnd)
    }
  }

  _onWowWindowClose(hwnd) {
    SetWorkingDir %A_ScriptDir%
    global __wow_dir
    if (this._name == "Wow.exe") {
	  if InStr(FileExist("Retail Backup"), "D") {
		wtf_dir :=   __wow_dir . "\_retail_"
		Run, "commit_WTF.cmd" "Retail Backup" "%wtf_dir%"
	  }
    } else if (this._name == "WowClassic.exe") {
	  if InStr(FileExist("Classic Backup"), "D") {
        wtf_dir := __wow_dir . "\_classic_era_"
        Run, "commit_WTF.cmd" "Classic Backup" "%wtf_dir%"
	  }
	  if InStr(FileExist("BC Classic Backup"), "D") {
        wtf_dir := __wow_dir . "\_classic_"
        Run, "commit_WTF.cmd" "BC Classic Backup" "%wtf_dir%"
	  }
    } else if (this._name == "WowT.exe") {
	  if InStr(FileExist("PTR Backup"), "D") {
        wtf_dir :=   __wow_dir . "\_ptr_"
        Run, "commit_WTF.cmd" "PTR Backup" "%wtf_dir%"
	  }
    }
  }

  run() {
    this._windowEvents.enable()
  }

  _isWowHwnd(hwnd) {
    this._name := this._getHwndProcessName(hwnd)
    return this._name == "Wow.exe"
        or this._name == "WowT.exe"
        or this._name == "WowClassic.exe"
        or this._name == "WowClassicB.exe"
  }

  _getHwndProcessName(hwnd) {
    winGet, App__getHwndProcessName__value, processName, % "ahk_id " . hwnd
    return App__getHwndProcessName__value
  }
}

app := new App()
app.run()
