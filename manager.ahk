#Requires AutoHotkey v2.0
#SingleInstance Force

; 各スクリプトを呼び出して常駐させる
Run('"' A_AhkPath '" "' A_ScriptDir '\ime-alt.ahk"')
Run('"' A_AhkPath '" "' A_ScriptDir '\call-pot.ahk"')
Run('"' A_AhkPath '" "' A_ScriptDir '\serve.ahk"')