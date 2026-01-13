#Requires AutoHotkey v2.0
#Include Lib\UIA.ahk

; 例：F1キーで「Fast」モードに切り替える
F1::SwitchAgentMode("Fast")

; 例：F2キーで「Planning」モードに切り替える
F2::SwitchAgentMode("Planning")

SwitchAgentMode(targetMode) {
    if !WinExist("ahk_exe Antigravity.exe")
        return

    WinActivate "ahk_exe Antigravity.exe"
    
    try {
        ; VSCodeのルート要素を取得
        vscode := UIA.ElementFromHandle("ahk_exe Antigravity.exe")

        ; ---------------------------------------------------------
        ; 1. トグルボタンを探す (名前が変わる問題の対策)
        ; ---------------------------------------------------------
        ; MatchMode: "RegEx" を使い、"Planning" または "Fast" のどちらでもヒットさせる
        ; ※他にもモードがある場合は "Planning|Fast|Chat" のようにパイプで繋ぐ
        toggleBtn := vscode.FindElement({
            Type: "Button", 
            Name: "Planning|Fast", 
            MatchMode: "RegEx"
        })

        ; すでに目的のモードなら何もしないで終了
        if (toggleBtn.Name == targetMode) {
            ToolTip "既に " targetMode " モードです"
            SetTimer () => ToolTip(), -1000
            return
        }

        ; ボタンをクリックしてメニューを開く
        toggleBtn.Click()

        ; ---------------------------------------------------------
        ; 2. 開いたダイアログから目的の項目を探してクリック
        ; ---------------------------------------------------------
        ; クリック直後はダイアログが出ていないので WaitElement で待つ (最大2秒)
        ; 画像によると選択肢は「テキスト」要素として見えている
        targetOption := vscode.WaitElement({
            Type: "Text", 
            Name: targetMode
        }, 2000)

        ; 項目をクリック
        ; (テキスト要素へのクリックで反応しない場合は、parent := targetOption.WalkTree("p") で親を取ってクリック)
        targetOption.Click()
        
        ToolTip targetMode " に変更しました"
        SetTimer () => ToolTip(), -1000

    } catch as e {
        MsgBox "エラーが発生しました: " e.Message
    }
}