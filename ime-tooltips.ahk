#Requires AutoHotkey v2.0

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
~vkF3::CheckAndShowIME()     ; 全角/半角
~CapsLock::CheckAndShowIME() ; CapsLock

; ==============================================================================
; ロジック
; ==============================================================================
CheckAndShowIME() {
    Sleep 50
    try {
        ret := IME_CHECK("A")
        if (ret == 1)
            ShowOSD(TextJp)
        else if (ret == 0)
            ShowOSD(TextEn)
    }
}

ShowOSD(text) {
    global OsdGui, OsdTxt
    
    OsdTxt.Value := text
    
    ; 画面中央の座標を計算
    x := (A_ScreenWidth - BoxSize) / 2
    y := (A_ScreenHeight - BoxSize) / 2
    
    ; GUI表示
    OsdGui.Show("NoActivate x" x " y" y)
    
    ; ★ここが修正ポイント：表示した直後に「最前面」を強制的に再適用する
    ; これにより、後から開いたウィンドウよりも手前に来ます
    WinSetAlwaysOnTop 1, OsdGui.Hwnd
    
    SetTimer HideGUI, -ShowTime
}

HideGUI() {
    OsdGui.Hide()
}

; ==============================================================================
; IME状態取得関数
; ==============================================================================
IME_CHECK(WinTitle) {
    try {
        hWnd := WinExist(WinTitle)
    } catch {
        return 0
    }
    if !hWnd
        return 0

    DetectHiddenWindows True
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
    
    if (DefaultIMEWnd) {
        return SendMessage(0x0283, 0x0005, 0, , "ahk_id " DefaultIMEWnd)
    }
    return 0
}