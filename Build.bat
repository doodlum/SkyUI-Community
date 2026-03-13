@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: SkyUI Community -- Build Helper
::
:: Usage:
::   Build.bat          -- choose mode interactively
::   Build.bat debug    -- compile + deploy to MOD_DEBUG_PATH
::   Build.bat release  -- full pipeline: compile -> BSA -> ZIP
::
:: Environment variables (optional, auto-detected if absent):
::   SkyrimSE_PATH    -- Skyrim SE install directory
::   MOD_DEBUG_PATH   -- MO2 mod folder to deploy into (debug only)
:: ============================================================================

:: ---- Parse argument ---------------------------------------------------------
set "MODE=%~1"
if /i "%MODE%"=="debug"   goto :mode_ok
if /i "%MODE%"=="release" goto :mode_ok
if "%MODE%"=="" goto :ask_mode

echo ERROR: Unknown mode "%MODE%". Valid values: debug, release
exit /b 1

:ask_mode
echo.
echo  Select build mode:
echo    [1] debug    - compile + deploy to MO2 mod folder
echo    [2] release  - full pipeline: compile -^> BSA -^> ZIP
echo.
set /p "MODE_CHOICE=Enter choice [1/2]: "
if "%MODE_CHOICE%"=="1" ( set "MODE=debug"   & goto :mode_ok )
if "%MODE_CHOICE%"=="2" ( set "MODE=release" & goto :mode_ok )
echo ERROR: Invalid choice.
exit /b 1

:mode_ok

:: ---- Locate Skyrim SE -------------------------------------------------------
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

:: ---- Debug mode: locate MO2 output folder -----------------------------------
if /i not "%MODE%"=="debug" goto :skip_mo2

if defined MOD_DEBUG_PATH (
    echo Deploying to: %MOD_DEBUG_PATH%
    echo.
    goto :skip_mo2
)

:: MOD_DEBUG_PATH not set -- ask, but allow empty to use the CMake default.
:mo2_ask
echo MOD_DEBUG_PATH is not set.
echo This is the MO2 mod folder where compiled files will be deployed.
echo Example: C:\Users\you\AppData\Local\ModOrganizer\Skyrim Special Edition\mods\SkyUI-dev
echo.
echo Press Enter to use the default output folder: build\debug\data
echo.
set "MO2_INPUT=__DEFAULT__"
set /p "MO2_INPUT=Enter MO2 mod folder path (or Enter for default): "

:: Detect "no input": sentinel unchanged means user pressed Enter without typing
if "!MO2_INPUT!"=="__DEFAULT__" set "MO2_INPUT="
:: Strip surrounding quotes the user may have typed
if not "!MO2_INPUT!"=="" set "MO2_INPUT=!MO2_INPUT:"=!"

if "!MO2_INPUT!"=="" (
    :: Empty -- leave MOD_DEBUG_PATH unset; CMake preset falls back to build\debug\data
    echo Using default: build\debug\data
) else (
    :: Sanity check: the drive root must be accessible.
    :: The mod folder need not exist yet -- MO2 creates it on first activation.
    :: Catch a wrong path (e.g. the example placeholder) early rather than
    :: getting a cryptic "failed to create directory" error from CMake.
    set "MO2_DRIVE=!MO2_INPUT:~0,3!"
    if not exist "!MO2_DRIVE!" (
        echo.
        echo ERROR: Drive "!MO2_INPUT:~0,2!" is not accessible.
        echo   Path entered: !MO2_INPUT!
        echo   Make sure the drive letter is correct.
        echo.
        goto :mo2_ask
    )
    if not exist "!MO2_INPUT!\" (
        echo.
        echo ERROR: Folder does not exist:
        echo   !MO2_INPUT!
        echo   Create it first in MO2: right-click -^> Create empty mod
        echo.
        goto :mo2_ask
    )
    set "MOD_DEBUG_PATH=!MO2_INPUT!"
    echo Deploying to: !MOD_DEBUG_PATH!
)
echo.

:skip_mo2

:: ---- Configure --------------------------------------------------------------
echo === Configuring [%MODE%] ===
echo.
cmake --preset %MODE% -Wno-dev
if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed.
    pause
    exit /b 1
)

:: ---- Build ------------------------------------------------------------------
echo.
echo === Building [%MODE%] ===
echo.
cmake --build --preset %MODE%
if errorlevel 1 (
    echo.
    echo ERROR: Build failed. See errors above.
    pause
    exit /b 1
)

:: ---- Done -------------------------------------------------------------------
echo.
echo === Done ===
echo.
if /i "%MODE%"=="debug" (
    if defined MOD_DEBUG_PATH (
        echo Deployed to:
        echo   !MOD_DEBUG_PATH!
    ) else (
        echo Deployed to: build\debug\data
    )
)
if /i "%MODE%"=="release" (
    echo Release artefacts in: build\release\
    echo   SkyUI_SE.bsa
    echo   SkyUI_SE-^<version^>.zip
)
echo.
pause
