@echo off
setlocal
REM =====================================================================
REM  Ecclesia - Preparation du backend pour le debug VSCode
REM  Appele automatiquement par .vscode/launch.json (preLaunchTask),
REM  AVANT que VSCode ne lance "flutter run".
REM  Enchaine : MySQL (XAMPP) -> Laravel serve (0.0.0.0:8000) -> adb reverse
REM  NE lance PAS flutter run : c'est VSCode qui s'en occupe.
REM =====================================================================

REM --- Configuration (a adapter si besoin) --------------------------------
set "PORT=8000"
set "LARAVEL_DIR=c:\projet\Ecclesia\Ecclesia"
set "ADB=C:\Android\sdk\platform-tools\adb.exe"
set "MYSQLD=C:\xampp\mysql\bin\mysqld.exe"
set "MYSQL_INI=C:\xampp\mysql\bin\my.ini"
REM -----------------------------------------------------------------------

REM --- 1. MySQL (XAMPP) : demarre seulement s'il ne tourne pas deja -------
tasklist /FI "IMAGENAME eq mysqld.exe" 2>nul | find /I "mysqld.exe" >nul
if errorlevel 1 (
    echo [1/3] Demarrage de MySQL...
    start "Ecclesia MySQL" /MIN "%MYSQLD%" --defaults-file="%MYSQL_INI%" --standalone
    timeout /t 4 /nobreak >nul
) else (
    echo [1/3] MySQL deja demarre. OK
)

REM --- 2. Laravel serve : sur toutes les interfaces, port %PORT% ----------
netstat -ano | findstr ":%PORT%" | findstr "LISTENING" >nul
if errorlevel 1 (
    echo [2/3] Demarrage du serveur Laravel sur 0.0.0.0:%PORT%...
    start "Ecclesia API" cmd /k "cd /d "%LARAVEL_DIR%" && php artisan serve --host=0.0.0.0 --port=%PORT%"
    timeout /t 3 /nobreak >nul
) else (
    echo [2/3] Serveur Laravel deja en ecoute sur le port %PORT%. OK
)

REM --- 3. adb reverse : redirige le port du telephone vers le PC ----------
echo [3/3] Configuration de adb reverse tcp:%PORT%...
"%ADB%" reverse tcp:%PORT% tcp:%PORT% >nul 2>&1
if errorlevel 1 (
    echo     ATTENTION : telephone non detecte par adb.
    echo     Verifiez le cable USB et que le debogage USB est active.
) else (
    echo     adb reverse OK.
)

REM Toujours rendre la main a VSCode (code 0) pour laisser flutter demarrer.
exit /b 0
