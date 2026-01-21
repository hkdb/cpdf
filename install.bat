@echo off
setlocal enabledelayedexpansion

echo.
echo  =========================================
echo   cpdf - The PDF Compressor (Windows)
echo              INSTALLATION
echo  =========================================
echo.

:: GitHub repository
set "GITHUB_REPO=hkdb/cpdf"

:: Detect architecture
set "ARCH=x86_64"
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=x86_64"

echo [*] Detected architecture: %ARCH%
echo.

:: Set install directory
set "INSTALL_DIR=%USERPROFILE%\.local\bin"

:: Create install directory if it doesn't exist
if not exist "%INSTALL_DIR%" (
    echo [*] Creating %INSTALL_DIR%...
    mkdir "%INSTALL_DIR%"
    if errorlevel 1 (
        echo [X] Failed to create install directory
        exit /b 1
    )
)

:: Check for local binary first
set "SCRIPT_DIR=%~dp0"
set "LOCAL_BINARY=%SCRIPT_DIR%dist\cpdf.exe"

if exist "%LOCAL_BINARY%" (
    echo [+] Found locally compiled binary
    copy /Y "%LOCAL_BINARY%" "%INSTALL_DIR%\cpdf.exe" >nul
    if errorlevel 1 (
        echo [X] Failed to copy binary
        exit /b 1
    )
    goto :installed
)

:: Download from GitHub releases
set "BINARY_NAME=cpdf-windows-%ARCH%.exe"
set "DOWNLOAD_URL=https://github.com/%GITHUB_REPO%/releases/latest/download/%BINARY_NAME%"

echo [*] Downloading %BINARY_NAME% from GitHub releases...
echo.

:: Try PowerShell to download
powershell -Command "& {Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALL_DIR%\cpdf.exe' -UseBasicParsing}" 2>nul
if errorlevel 1 (
    echo [X] Failed to download cpdf from GitHub
    echo [!] URL: %DOWNLOAD_URL%
    exit /b 1
)

:installed
echo.
echo [+] cpdf installed successfully to %INSTALL_DIR%\cpdf.exe
echo.
echo [!] Make sure %INSTALL_DIR% is in your PATH environment variable.
echo.
echo     To add to PATH temporarily:
echo       set PATH=%%PATH%%;%INSTALL_DIR%
echo.
echo     To add to PATH permanently, run as Administrator:
echo       setx PATH "%%PATH%%;%INSTALL_DIR%"
echo.

:: Check if ghostscript is available
where gs >nul 2>&1
if errorlevel 1 (
    echo [!] WARNING: Ghostscript (gs) not found in PATH.
    echo     cpdf requires Ghostscript to work.
    echo     Download from: https://ghostscript.com/releases/gsdnld.html
    echo.
)

echo  =========================================
echo              COMPLETED
echo  =========================================
echo.

endlocal
