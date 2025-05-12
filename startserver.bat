@echo off
set MINECRAFT_VERSION=1.20.1
set FORGE_VERSION=47.3.0

set INSTALLER="%~dp0forge-1.20.1-%FORGE_VERSION%-installer.jar"
set FORGE_URL="http://files.minecraftforge.net/maven/net/minecraftforge/forge/%MINECRAFT_VERSION%-%FORGE_VERSION%/forge-%MINECRAFT_VERSION%-%FORGE_VERSION%-installer.jar"

:JAVA
if not defined SPMC_JAVA (
    set SPMC_JAVA=java
)

"%SPMC_JAVA%" -version 1>nul 2>nul || (
   echo Minecraft 1.20.1 inditasahoz szukseged lesz minimum Java 17-re!
   echo Innen be tudod szerezni: https://www.oracle.com/java/technologies/downloads/#jdk23-windows
   pause
   exit /b 1
)

:FORGE
setlocal
cd /D "%~dp0"
if not exist "libraries" (
    echo Forge nincs telepitve, telepites megkezdve.
    if not exist %INSTALLER% (
        echo A Forge telepito nem talalhato. Letoltes inditasa...
        bitsadmin.exe /rawreturn /nowrap /transfer forgeinstaller /download /priority FOREGROUND %FORGE_URL% %INSTALLER%
    )
    
    echo Forge telepito futtatasa...
    "%SPMC_JAVA%" -jar %INSTALLER% -installServer
)

if not exist "server.properties" (
    (
        echo allow-flight=true
        echo motd=The Invasion
        echo max-tick-time=-1
    )> "server.properties"
)

if "%SPMC_INSTALL_ONLY%" == "true" (
    echo INSTALL_ONLY: complete
    goto:EOF
)

for /f tokens^=2-5^ delims^=.-_^" %%j in ('"%SPMC_JAVA%" -fullversion 2^>^&1') do set "jver=%%j"
if not %jver% geq 17  (
    echo Minecraft 1.20.1 futtatasahoz minimum Java 17 szukseges!
    echo Telepitett Java verzio: %jver%
    pause
    exit /b 1
) 

:START
"%SPMC_JAVA%" @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-%FORGE_VERSION%/win_args.txt nogui

if "%SPMC_RESTART%" == "false" ( 
    goto:EOF 
)

echo Automatikus ujrainditas 10 masodperc mulva. (Nyomd meg a Ctrl + C kombinaciot az ujrainditas megallitasahoz)
timeout /t 10 /nobreak > NUL
goto:START
