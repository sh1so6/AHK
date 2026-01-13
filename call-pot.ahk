#Requires AutoHotkey v2.0

; Ctrl+C はそのまま通す（コピー実行）
~^c::
{
    static lastTime := 0
    
    ; 前回の入力から400ミリ秒(0.4秒)以内かどうかを判定
    ; ※連打速度を緩めたい場合は 400 を 500 などに増やしてください
    if (A_TickCount - lastTime < 400)
    {
        ; --- 2回連続押しの処理 ---
        
        ; Pot-Appのショートカットを送る（例: Ctrl+Alt+X）
        Send "^!x"
        
        ; 3連打したときにまた反応しないようタイマーをリセット
        lastTime := 0
    }
    else
    {
        ; --- 1回目の処理 ---
        lastTime := A_TickCount
    }
    
    ; 【重要】キー押しっぱなしによる連続発火（オートリピート）を防ぐため、
    ; Cキーが離されるのを待ってから処理を終了する
    KeyWait "c"
}