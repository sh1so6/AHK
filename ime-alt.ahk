#Requires AutoHotkey v2.0
#SingleInstance Force

; --------------------------------------------------------------
; 1. CapsLockを「半角/全角」キーにリマップ
; --------------------------------------------------------------
CapsLock::Send "{vkF3sc029}"

; --------------------------------------------------------------
; 2. サスペンド（一時停止）設定
; --------------------------------------------------------------
#SuspendExempt
!\:: {
    Suspend(-1)
    
    ; 状態に合わせてメッセージと色を設定
    msg := A_IsSuspended ? "SCRIPT STOPPED" : "SCRIPT ACTIVE"
    color := A_IsSuspended ? "FF4444" : "44FF44"
    
    ShowMessage(msg, color)
}
#SuspendExempt False

; --------------------------------------------------------------
; 3. メッセージ表示関数（修正箇所）
; --------------------------------------------------------------
ShowMessage(text, color) {
    static myGui := ""
    
    ; 【重要】前回表示したGUIが残っていたら消す
    ; エラー回避のため try を使い、消去後に変数を空にする
    if (myGui) {
        try myGui.Destroy()
        myGui := ""
    }
    
    ; GUIの作成
    myGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    myGui.BackColor := "1A1A1A"
    myGui.SetFont("s32 w700 c" color, "Segoe UI")
    myGui.Add("Text", "Center", "  " text "  ")
    
    ; 表示設定
    myGui.Show("xCenter yCenter NoActivate")
    WinSetTransparent(200, myGui)
    
    ; 1.5秒後に消すタイマー
    SetTimer(DestroyGui, -1500)

    ; 内部関数: GUIを安全に消す処理
    DestroyGui() {
        try myGui.Destroy()
        myGui := "" ; 変数を空に戻してリセット完了
    }
}

; --------------------------------------------------------------
; 4. Altキーの空打ち設定
; --------------------------------------------------------------
; 左Alt空打ち → 変換キー (IME ON)
~LAlt Up::
{
    if (A_PriorKey = "LAlt")
        Send "{vk1C}"
}

; 右Alt空打ち → 無変換キー (IME OFF)
~RAlt Up::
{
    if (A_PriorKey = "RAlt")
        Send "{vk1D}"
}