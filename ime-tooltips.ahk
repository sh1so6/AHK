#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; 設定エリア
; ==============================================================================
ShowTime := 500      ; 表示時間（ミリ秒）
TextJp   := "あ"     ; 日本語オン
TextEn   := "A"      ; 英語オフ

; デザイン設定
FontSize   := 100           ; 文字サイズ
BoxSize    := 180           ; 正方形の一辺のサイズ(px)
FontName   := "Segoe UI"    ; フォント
FontColor  := "FFFFFF"      ; 文字色
BgColor    := "333333"      ; 背景色

; ==============================================================================
; GUI作成
; ==============================================================================
; +AlwaysOnTop: 最前面 (念のためここにも記述)
; -Caption: タイトルバーなし
; +ToolWindow: タスクバー非表示
; +E0x08000000: ウインドウをアクティブにしない
; +Border: 枠線あり
OsdGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +Border")
OsdGui.BackColor := BgColor
OsdGui.SetFont("s" FontSize " w700", FontName)
OsdGui.MarginX := 0
OsdGui.MarginY := 0

OsdTxt := OsdGui.Add("Text", "w" BoxSize " h" BoxSize " Center 0x200 c" FontColor, "")

; ==============================================================================
; キーフック設定
; ==============================================================================
~vkF3::DeferCheck()     ; 全角/半角
~vkF4::DeferCheck()     ; 全角/半角
~vk1C::DeferCheck()     ; 変換
~vk1D::DeferCheck()     ; 無変換
~vkF2::DeferCheck()     ; ひらがな/カタカナ
~vkF0::DeferCheck()     ; 英数
~CapsLock::DeferCheck() ; CapsLock

DeferCheck() {
    ; 60-120msあたりで調整
    SetTimer(CheckAndShowIME, -80)
}

; ==============================================================================
; ロジック
; ==============================================================================
CheckAndShowIME() {
    try {
        ret := IME_GetOpenStatus("A")
        if (ret == 1)
            ShowOSD(TextJp)
        else if (ret == 0)
            ShowOSD(TextEn)
    }
}

ShowOSD(text) {
    global OsdGui, OsdTxt, BoxSize, ShowTime
    OsdTxt.Value := text
    ; 画面中央の座標を計算
    x := (A_ScreenWidth - BoxSize) / 2
    y := (A_ScreenHeight - BoxSize) / 2
    ; GUI表示
    OsdGui.Show("NoActivate x" x " y" y)
    WinSetAlwaysOnTop(1, OsdGui.Hwnd)
    SetTimer(HideGUI, -ShowTime)
}

HideGUI() {
    global OsdGui
    OsdGui.Hide()
}

; ==============================================================================
; IME状態取得関数
; ==============================================================================
IME_GetOpenStatus(WinTitle := "A") {
    hWnd := WinExist(WinTitle)
    if !hWnd
        return 0
    if WinActive(WinTitle) {
        fh := GetFocusedHwnd()
        if (fh)
            hwnd := fh
    }

    imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hWnd, "Ptr")
    if !imeWnd
        return 0

    return DllCall("user32\SendMessageW",
        "Ptr", imeWnd,
        "UInt", 0x0283,
        "Ptr", 0x0005,
        "Ptr", 0)
}

GetFocusedHwnd() {
    ptrSize := A_PtrSize
    cbSize := 4 + 4 + (ptrSize * 6) + 16 ;GUITHREADINFO
    buf := Buffer(cbSize, 0)
    NumPut("UInt", cbSize, buf, 0)

    if !DllCall("user32\GetGUIThreadInfo", "UInt", 0, "Ptr", buf)
        return 0

    ;hwndFocusはGUITHREADINFO内にある
    ;先頭8バイト以降にhwndActive(Ptr)があり、その次がhwndFocus(Ptr)
    return NumGet(buf, 8 + ptrSize, "Ptr")
}