#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent ; ホットキーが無くてもスクリプトを常駐させるための設定

; =========================================================
; 1. 変数でPID（プロセスID）を受け取る準備
; =========================================================
global pid_opencode := 0
global pid_miniserve := 0
global pid_ollama := 0

; ※パスは先輩の環境の「実体パス」に書き換えてください
path_node      := "C:\Users\9808g\AppData\Local\mise\installs\node\22.x.x\bin\node.exe"
path_opencode  := "C:\Users\9808g\AppData\Local\mise\installs\node\22.x.x\bin\opencode" ; ※重要：.cmdではなく実体のJSファイルを指定します
path_miniserve := "C:\Users\9808g\AppData\Local\mise\installs\miniserve\xxx\miniserve.exe"
path_ollama    := "C:\Users\9808g\AppData\Local\Programs\Ollama\ollama.exe"

; =========================================================
; 2. サーバー群の起動とPIDの取得 (&変数名 で取得できます)
; =========================================================
Run('"' path_node '" "' path_opencode '" web', , "Hide", &pid_opencode)
Run('"' path_miniserve '" E:/Dev/TemparMonkey -i 127.0.0.1 -p 18080 --header "Access-Control-Allow-Origin:*" --header "Access-Control-Allow-Methods:GET,OPTIONS"', , "Hide", &pid_miniserve)
Run('"' path_ollama '" serve', , "Hide", &pid_ollama)

; =========================================================
; 3. スクリプト終了時（リロード時）のクリーンアップ処理
; =========================================================
OnExit(CleanupProcesses)

CleanupProcesses(ExitReason, ExitCode) {
    if ProcessExist(pid_opencode)
        ProcessClose(pid_opencode)
    if ProcessExist(pid_miniserve)
        ProcessClose(pid_miniserve)
    if ProcessExist(pid_ollama)
        ProcessClose(pid_ollama)
}