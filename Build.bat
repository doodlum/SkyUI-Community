@echo off
setlocal enabledelayedexpansion

:: Check for SkyrimSE_PATH
if defined SkyrimSE_PATH goto :found

:: Try to find Skyrim SE via Steam registry
for %%R in (
    "HKLM\SOFTWARE\WOW6432Node\Valve\Steam"
    "HKLM\SOFTWARE\Valve\Steam"
) do (
    for /f "tokens=2*" %%A in ('reg query %%R /v InstallPath 2^>nul') do (
        set "STEAM_PATH=%%B"
    )
)

if not defined STEAM_PATH goto :notfound

:: Check default Steam library
set "CANDIDATE=%STEAM_PATH%\steamapps\common\Skyrim Special Edition"
if exist "%CANDIDATE%\SkyrimSE.exe" (
    set "SkyrimSE_PATH=%CANDIDATE%"
    goto :confirm
)

:: Parse Steam library folders for additional locations
set "VDF=%STEAM_PATH%\steamapps\libraryfolders.vdf"
if not exist "%VDF%" goto :notfound

for /f "usebackq tokens=1,2 delims=	 " %%A in ("%VDF%") do (
    set "KEY=%%~A"
    set "VAL=%%~B"
    if "!KEY!"=="path" (
        set "CANDIDATE=!VAL:\\\=\!"
        set "CANDIDATE=!CANDIDATE!\steamapps\common\Skyrim Special Edition"
        if exist "!CANDIDATE!\SkyrimSE.exe" (
            set "SkyrimSE_PATH=!CANDIDATE!"
            goto :confirm
        )
    )
)

goto :notfound

:confirm
set "SkyrimSE_PATH=%SkyrimSE_PATH:\\=\%"
echo Found Skyrim SE at: %SkyrimSE_PATH%
echo.
set /p "USE_FOUND=Use this path? [Y/n] "
if /i "%USE_FOUND%"=="n" goto :manual
goto :found

:notfound
echo Could not find Skyrim SE automatically.
echo.

:manual
set /p "SkyrimSE_PATH=Enter your Skyrim SE installation path: "

:: Remove surrounding quotes if present
set "SkyrimSE_PATH=%SkyrimSE_PATH:"=%"

if not exist "%SkyrimSE_PATH%\SkyrimSE.exe" (
    echo.
    echo ERROR: SkyrimSE.exe not found at: %SkyrimSE_PATH%
    echo.
    pause
    exit /b 1
)

:found
echo Using Skyrim SE at: %SkyrimSE_PATH%
echo.

:: Configure
echo --- Configuring ---
cmake --preset build -Wno-dev
if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed.
    pause
    exit /b 1
)

:: Build
echo.
echo --- Building ---
cmake --build build
if errorlevel 1 (
    echo.
    echo ERROR: Build failed.
    pause
    exit /b 1
)

echo.
echo --- Done ---
echo Release zip created in the release/ folder.
echo.
pause
