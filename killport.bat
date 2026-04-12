@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:START
cls
echo ╔════════════════════════════════════════╗
echo ║      🔧 端口进程管理工具 v1.1        ║
echo ╠════════════════════════════════════════╣
echo ║  输入端口号 → 关闭进程                 ║
echo ║  直接回车   → 默认 8080               ║
echo ║  输入 q     → 退出程序                ║
echo ╚════════════════════════════════════════╝
echo.

set /p PORT="请输入端口号 [默认:8080] > "

if /i "%PORT%"=="q" goto END
if "%PORT%"=="" set PORT=8080

echo.
echo [🔍] 正在扫描端口 %PORT% ...
echo.

:: 使用临时文件去重
set TEMP_FILE=%temp%\pid_list_%RANDOM%.txt
netstat -ano | findstr :%PORT% | findstr LISTENING > %TEMP_FILE%

set FOUND=0
set "PROCESSED_PIDS="

for /f "tokens=5" %%a in (%TEMP_FILE%) do (
    set "CURRENT_PID=%%a"
    
    :: 检查是否已经处理过这个PID
    echo !PROCESSED_PIDS! | findstr /C:"!CURRENT_PID!" >nul
    if errorlevel 1 (
        set "PROCESSED_PIDS=!PROCESSED_PIDS! !CURRENT_PID!"
        set FOUND=1
        echo   [📌] 发现进程 PID: !CURRENT_PID!
        taskkill /PID !CURRENT_PID! /F >nul 2>&1
        if !errorlevel!==0 (
            echo   [✅] 已终止进程 !CURRENT_PID!
        ) else (
            echo   [❌] 终止失败，可能需要管理员权限
        )
        echo.
    )
)

del %TEMP_FILE% 2>nul

if %FOUND%==0 (
    echo   [ℹ️] 未找到占用端口 %PORT% 的进程
) else (
    echo   [🎉] 端口 %PORT% 已释放
)

echo.
echo 按任意键继续...
pause >nul
goto START

:END
echo.
echo [👋] 再见！
timeout /t 1 /nobreak >nul
exit
