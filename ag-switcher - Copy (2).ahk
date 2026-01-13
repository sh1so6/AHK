#Requires AutoHotkey v2.0
#Include Lib\UIA.ahk

; F1キーでモード切り替え（Planning <-> Fast）
F1::ToggleAntigravityMode()

ToggleAntigravityMode() {
    targetExe := "ahk_exe Antigravity.exe"
    
    if !WinExist(targetExe)
        return
    
    WinActivate targetExe

    try {
        ; 1. ルート（メインウィンドウ）を取得
        agApp := UIA.ElementFromHandle(targetExe)

        ; 2. "飛び石" アプローチで範囲を絞る
        ; 階層ログにあった「Application -> Window -> Document」という構造を利用します。
        ; 間のGroupは FindElement が勝手に深掘りして探してくれるので無視してOKです。

        targetContainer := agApp.FindElement({Type: "Document"}) 
                                .FindElement({Type: "Window"}) 
                                .FindElement({Type: "Pane"}) 
        
        ; 3. 絞り込んだ範囲(Document)の中から、正規表現でボタンを探す
        ; 8階層下のボタンでも、ここからなら一瞬で見つかります
        toggleBtn := targetContainer.FindElement({
            Type: "Button", 
            Name: "Planning|Fast",  ; 名前が変わってもOK
            MatchMode: "RegEx"
        })

        ; --- ここから下はクリック＆メニュー操作 ---

        currentMode := toggleBtn.Name
        targetMode := (currentMode == "Planning") ? "Fast" : "Planning"
        
        toggleBtn.Click()

        ; メニュー項目が出るのを待つ
        ; メニューはポップアップ扱いなので、念のためルート(agApp)から探すのが安全です
        targetOption := agApp.WaitElement({
            Type: "Text", 
            Name: targetMode
        }, 2000)
        
        targetOption.Click()

        ToolTip "Mode changed to: " targetMode
        SetTimer () => ToolTip(), -1000

    } catch as e {
        MsgBox "エラー: 要素が見つかりませんでした`n" e.Message
    }
}