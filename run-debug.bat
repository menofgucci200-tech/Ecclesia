@echo off
setlocal enabledelayedexpansion
title Ecclesia - Debug Launcher

REM =====================================================================
REM  Ecclesia - Lanceur de debug (telephone Android via USB)
REM  Enchaine : MySQL (XAMPP) -> Laravel serve -> adb reverse -> flutter run
REM  Double-cliquez sur ce fichier pour tout demarrer.
REM =====================================================================

REM --- Configuration (a adapter si besoin) ---------------------------------
set "DEVICE=14733405BW009338"
set "PORT=8000"
set "LARAVEL_DIR=c:\projet\Ecclesia\Ecclesia"
set "FLUTTER_DIR=c:\projet\Ecclesia\ecclesia_"
set "ADB=C:\Android\sdk\platform-tools\adb.exe"
set "MYSQLD=C:\xampp\mysql\bin\mysqld.exe"
set "MYSQL_INI=C:\xampp\mysql\bin\my.ini"
REM ------------------------------------------------------------------------

echo.
echo ==========================================================
echo   ECCLESIA - Demarrage de l'environnement de debug
echo ==========================================================
echo.

REM --- 1. MySQL (XAMPP) : demarre seulement s'il ne tourne pas deja ---------
tasklist /FI "IMAGENAME eq mysqld.exe" 2>nul | find /I "mysqld.exe" >nul
if errorlevel 1 (
    echo [1/4] Demarrage de MySQL...
    start "Ecclesia MySQL" /MIN "%MYSQLD%" --defaults-file="%MYSQL_INI%" --standalone
    timeout /t 4 /nobreak >nul
) else (
    echo [1/4] MySQL deja demarre. OK
)

REM --- 2. Laravel serve : sur toutes les interfaces, port %PORT% ------------
netstat -ano | findstr ":%PORT%" | findstr "LISTENING" >nul
if errorlevel 1 (
    echo [2/4] Demarrage du serveur Laravel sur 0.0.0.0:%PORT%...
    start "Ecclesia API" cmd /k "cd /d "%LARAVEL_DIR%" && php artisan serve --host=0.0.0.0 --port=%PORT%"
    timeout /t 3 /nobreak >nul
) else (
    echo [2/4] Serveur Laravel deja en ecoute sur le port %PORT%. OK
)

REM --- 3. adb reverse : redirige le port du telephone vers le PC ------------
echo [3/4] Configuration de adb reverse (tcp:%PORT%)...
"%ADB%" reverse tcp:%PORT% tcp:%PORT% >nul 2>&1
if errorlevel 1 (
    echo     ATTENTION : le telephone n'est pas detecte par adb.
    echo     Verifiez le cable USB et que le debogage USB est active, puis relancez.
    "%ADB%" devices
    echo.
    pause
    exit /b 1
)
echo     adb reverse OK.

REM --- 4. flutter run sur le telephone --------------------------------------
echo [4/4] Lancement de l'application sur le telephone...
echo.
cd /d "%FLUTTER_DIR%"
flutter run -d %DEVICE%

REM Si le device n'est plus trouve, flutter proposera la liste des appareils.
echo.
echo Session de debug terminee.
pause
