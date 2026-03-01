#Requires AutoHotkey v2.0

; Ctrl + Shift + V で実行
^+v::
{
    ; クリップボードが空なら何もしない
    if (A_Clipboard = "")
        return

    ; 送信モードを Event に設定（入力速度を少し安定させるため）
    SetKeyDelay 10, 10
    SendEvent "{Text}" A_Clipboard
}