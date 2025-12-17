#Requires AutoHotkey v2.0

; ==============================================================================
; 設定エリア
; ==============================================================================
ShowTime := 700      ; 表示時間（ミリ秒）
TextJp   := "あ"     ; 日本語オン
TextEn   := "A"      ; 英語オフ

; デザイン設定
FontSize   := 18            ; 文字サイズ
BoxSize    := 43            ; 正方形の一辺のサイズ(px) 文字サイズに合わせて調整してね
FontName   := "YuGothic UI"   ; フォント
FontColor  := "000000"      ; 文字色
BgColor    := "FFFFFF"      ; 背景色

; 座標モード
CoordMode "Caret", "Screen"
CoordMode "Mouse", "Screen"

; ==============================================================================
; GUI作成
; ==============================================================================
; +AlwaysOnTop: 最前面
; -Caption: タイトルバーなし
; +ToolWindow: タスクバー非表示
; +E0x08000000: ウインドウをアクティブにしない(WS_EX_NOACTIVATE)
; +Border: 枠線あり
OsdGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +Border")
OsdGui.BackColor := BgColor
OsdGui.SetFont("s" FontSize " w700", FontName)

; マージンを0にすることで、GUIのサイズ＝テキストコントロールのサイズにする
OsdGui.MarginX := 0
OsdGui.MarginY := 0

; テキストコントロール作成
; w, h: 幅と高さをBoxSizeで指定して正方形にする
; 0x200: 垂直方向の中央揃え (SS_CENTERIMAGE)
; Center: 水平方向の中央揃え
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
    
    cX := 0, cY := 0, mX := 0, mY := 0
    if CaretGetPos(&cX, &cY) {
        ; 正方形のサイズ分も考慮して位置調整
        tX := cX
        tY := cY + 40 
    } else {
        MouseGetPos &mX, &mY
        tX := mX + 20
        tY := mY + 20
    }

    ; GUI表示 (NoActivateでフォーカスを奪わない)
    ; サイズはテキストコントロール側で固定したのでAutoSizeでOK
    OsdGui.Show("NoActivate AutoSize x" tX " y" tY)
    
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