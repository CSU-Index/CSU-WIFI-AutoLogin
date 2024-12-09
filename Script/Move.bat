@echo off
chcp 65001 & cls
title CSUAutoLogin安装程序
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
setlocal enabledelayedexpansion

:: 设置源目录和目标目录
set "source_folder=%cd%\auto_login"
set "target_folder=%APPDATA%\CSUAutoLogin"

:: 检查源目录是否存在，如果不存在则退出
if not exist "%source_folder%" (
    echo ERROR: 位置 "%source_folder%" 不存在，请重新输入
    exit /b
)

:: 检查目标目录是否存在，如果不存在则创建
if not exist "%target_folder%" (
    echo WARNING: 位置 "%target_folder%" 不存在，正在创建…
    mkdir "%target_folder%"
)

:: 遍历源目录及其子目录中的所有文件夹
for /d /r "%source_folder%" %%d in (*) do (
    set "subdir=%%d"
    set "relative_path=!subdir:%source_folder%=!"
    set "target_subdir=%target_folder%!relative_path!"

    :: 创建目标子目录
    if not exist "!target_subdir!" (
        mkdir "!target_subdir!"
    )

    :: 移动文件夹内容
    for %%f in ("!subdir!\*") do (
        move "%%f" "!target_subdir!" >nul
    )
)

:: 移动源目录中的所有文件
for /r "%source_folder%" %%f in (*) do (
    set "file=%%f"
    set "relative_path=!file:%source_folder%=!"
    set "target_file=%target_folder%!relative_path!"

    :: 创建目标子目录
    if not exist "!target_file!" (
        move "%%f" "!target_file!" >nul
    )
)

:: 递归删除空文件夹
:delEmptyDirs
for /f "delims=" %%d in ('dir "%source_folder%" /ad /b /s ^| sort /r') do (
    rd "%%d" 2>nul
)
rd "%source_folder%" 2>nul

echo 所有文件和文件夹移动成功
pause