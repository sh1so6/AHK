#Requires AutoHotkey v2.0
#Include Lib\UIA.ahk

; スクリプト起動時にGUIを表示
ShowAntigravityManager()

ShowAntigravityManager() {
    targetExe := "ahk_exe Antigravity.exe"
    
    ; Antigravityが見つからない場合
    if !WinExist(targetExe) {
        MsgBox "Antigravityが起動していません。"
        ExitApp
    }

    ; GUI作成
    myGui := Gui(, "Antigravity Mode Manager")
    myGui.SetFont("s10", "Segoe UI")
    
    ; リストビュー: [ウィンドウタイトル] [現在のモード] [HWND(隠し)]
    lv := myGui.Add("ListView", "w600 h200 Grid", ["Window Title", "Current Mode", "HWND"])
    
    ; 下部のボタン
    btnSwitch := myGui.Add("Button", "w150 Default", "Switch Mode")
    btnRefresh := myGui.Add("Button", "w100 yp", "Refresh List")

    ; --- イベント割り当て ---
    ; 切り替え実行
    btnSwitch.OnEvent("Click", (*) => ToggleSelected(lv))
    lv.OnEvent("DoubleClick", (*) => ToggleSelected(lv))
    
    ; リスト更新
    btnRefresh.OnEvent("Click", (*) => RefreshList(lv, targetExe))
    
    ; 初回リスト読み込み
    RefreshList(lv, targetExe)
    
    myGui.Show()
}

; リストを更新する関数
RefreshList(lv, targetExe) {
    lv.Delete() ; リストクリア
    
    ; 全てのAntigravityのウィンドウIDを取得
    idList := WinGetList(targetExe)
    
    if (idList.Length == 0)
        return

    for hwnd in idList {
        try {
            ; ウィンドウタイトル取得
            title := WinGetTitle(hwnd)
            ; 可視ウィンドウのみ対象にするフィルタ（不要なら外してもOK）
            if (title == "")
                continue

            ; UIAでそのウィンドウの「現在のモード」を取得しに行く
            currentMode := GetCurrentMode(hwnd)
            
            ; リストに追加
            lv.Add("", title, currentMode, hwnd)
        } catch {
            ; 読み込み中のウィンドウなどでエラーが出ても無視
            continue
        }
    }
    
    ; カラム幅の自動調整
    lv.ModifyCol(1, 400) ; Title
    lv.ModifyCol(2, 100) ; Mode
    lv.ModifyCol(3, 0)   ; HWNDは隠す
}

; 指定されたHWNDの現在のモードテキストを取得する関数
GetCurrentMode(hwnd) {
    try {
        winEl := UIA.ElementFromHandle(hwnd)
        
        ; 例の階層構造を使ってボタンを探す
        ; Application -> Window -> Document -> Button
        targetContainer := winEl.FindElement({Type: "Document"})
                                .FindElement({Type: "Window"})
                                .FindElement({Type: "Pane"})
        
        btn := targetContainer.FindElement({
            Type: "Button", 
            Name: "Planning|Fast", 
            MatchMode: "RegEx"
        })
        
        return btn.Name ; "Planning" or "Fast"
    } catch {
        return "Unknown" ; ボタンが見つからない場合
    }
}

; リストで選択されたウィンドウのモードを切り替える関数
ToggleSelected(lv) {
    row := lv.GetNext(0) ; 選択された行番号
    if (row == 0)
        return

    hwnd := lv.GetText(row, 3)     ; 隠しカラムからHWND取得
    currentMode := lv.GetText(row, 2) ; 現在のモード
    
    if (currentMode == "Unknown") {
        MsgBox "このウィンドウのモードは操作できません。"
        return
    }

    ; ウィンドウをアクティブにする
    WinActivate "ahk_id " hwnd
    WinWaitActive "ahk_id " hwnd, , 2

    try {
        ; --- ここは前回の切り替えロジックと同じ ---
        winEl := UIA.ElementFromHandle(hwnd)
        
        ; ボタン再取得（参照が切れている可能性があるため）
        targetContainer := winEl.FindElement({Type: "Document"})
                                .FindElement({Type: "Window"})
                                .FindElement({Type: "Pane"})
                                
        toggleBtn := targetContainer.FindElement({
            Type: "Button", 
            Name: "Planning|Fast", 
            MatchMode: "RegEx"
        })
        
        targetMode := (toggleBtn.Name == "Planning") ? "Fast" : "Planning"
        
        toggleBtn.Click()
        
        ; メニュー選択 (ルートから待つ)
        targetOption := winEl.WaitElement({Type: "Text", Name: targetMode}, 2000)
        targetOption.Click()
        
        ; 成功したらリスト上の表示も更新しておく
        lv.Modify(row, "Col2", targetMode)
        
    } catch as e {
        MsgBox "切り替えに失敗しました: " e.Message
    }
}