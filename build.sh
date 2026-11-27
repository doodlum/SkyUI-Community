#!/usr/bin/env bash
# SkyUI Community -- Build Helper (Linux)
#
# Usage:
#   ./build.sh            -- choose mode interactively
#   ./build.sh debug      -- compile + deploy to MOD_DEBUG_PATH
#   ./build.sh release    -- full pipeline: compile -> BSA -> ZIP
#
# Environment variables (optional, auto-detected if absent):
#   SkyrimSE_PATH    -- Skyrim SE install directory
#   MOD_DEBUG_PATH   -- mod folder for debug deployment

set -euo pipefail

# --- Parse argument ---

MODE="${1:-}"

case "${MODE,,}" in
    debug|release) MODE="${MODE,,}" ;;
    "")
        echo
        echo " Select build mode:"
        echo "   [1] debug    - compile + deploy to mod folder"
        echo "   [2] release  - full pipeline: compile -> BSA -> ZIP"
        echo
        read -rp "Enter choice [1/2]: " MODE_CHOICE
        case "$MODE_CHOICE" in
            1) MODE=debug ;;
            2) MODE=release ;;
            *) echo "ERROR: Invalid choice."; exit 1 ;;
        esac
        ;;
    *)
        echo "ERROR: Unknown mode '${MODE}'. Valid values: debug, release"
        exit 1
        ;;
esac

# --- Locate Skyrim SE ---

if [[ -z "${SkyrimSE_PATH:-}" ]]; then
    # Standard Steam library on Linux
    DEFAULT_PATH="$HOME/.local/share/Steam/steamapps/common/Skyrim Special Edition"

    if [[ -f "${DEFAULT_PATH}/SkyrimSE.exe" ]]; then
        echo "Found Skyrim SE at: ${DEFAULT_PATH}"
        echo
        read -rp "Use this path? [Y/n] " USE_FOUND
        if [[ "${USE_FOUND,,}" != "n" ]]; then
            SkyrimSE_PATH="${DEFAULT_PATH}"
        fi
    fi

    if [[ -z "${SkyrimSE_PATH:-}" ]]; then
        # Search additional Steam libraries from libraryfolders.vdf
        VDF="$HOME/.local/share/Steam/steamapps/libraryfolders.vdf"
        if [[ -f "$VDF" ]]; then
            while IFS= read -r line; do
                [[ ! "$line" =~ \"path\"[[:space:]]+\"([^\"]+)\" ]] && continue
                CANDIDATE="${BASH_REMATCH[1]}/steamapps/common/Skyrim Special Edition"
                [[ ! -f "${CANDIDATE}/SkyrimSE.exe" ]] && continue
                echo "Found Skyrim SE at: ${CANDIDATE}"
                echo
                read -rp "Use this path? [Y/n] " USE_FOUND
                if [[ "${USE_FOUND,,}" != "n" ]]; then
                    SkyrimSE_PATH="${CANDIDATE}"
                    break
                fi
            done < "$VDF"
        fi
    fi

    if [[ -z "${SkyrimSE_PATH:-}" ]]; then
        echo "Could not find Skyrim SE automatically."
        echo
        read -rp "Enter your Skyrim SE installation path: " SkyrimSE_PATH
        if [[ -z "${SkyrimSE_PATH}" ]]; then
            echo "ERROR: Path cannot be empty."
            exit 1
        fi
        if [[ ! -f "${SkyrimSE_PATH}/SkyrimSE.exe" ]]; then
            echo
            echo "ERROR: SkyrimSE.exe not found at: ${SkyrimSE_PATH}"
            exit 1
        fi
    fi
fi

echo "Using Skyrim SE at: ${SkyrimSE_PATH}"
export SkyrimSE_PATH
echo

# --- Debug mode: locate output folder ---

if [[ "${MODE,,}" == "debug" && -z "${MOD_DEBUG_PATH:-}" ]]; then
    echo "MOD_DEBUG_PATH is not set."
    echo "This is the mod folder where compiled files will be deployed."
    echo "Example: /home/you/.local/share/ModOrganizer/Skyrim Special Edition/mods/SkyUI-dev"
    echo
    echo "Press Enter to use the default output folder: dist"
    echo
    read -rp "Enter mod folder path (or Enter for default): " DEBUG_PATH_INPUT

    if [[ -z "$DEBUG_PATH_INPUT" ]]; then
        echo "Using default: dist"
    elif [[ ! -d "$DEBUG_PATH_INPUT" ]]; then
        echo
        echo "ERROR: Folder does not exist:"
        echo "  ${DEBUG_PATH_INPUT}"
        echo "  Create the folder first, then re-run."
        exit 1
    else
        MOD_DEBUG_PATH="$DEBUG_PATH_INPUT"
        export MOD_DEBUG_PATH
        echo "Deploying to: ${MOD_DEBUG_PATH}"
    fi
    echo
fi

# --- Configure ---

echo "=== Configuring [${MODE}] ==="
echo
cmake --preset "${MODE}" -Wno-dev
echo

# --- Build ---

echo "=== Building [${MODE}] ==="
echo
cmake --build --preset "${MODE}"

# --- Done ---

echo
echo "=== Done ==="
echo
if [[ "${MODE,,}" == "debug" ]]; then
    if [[ -n "${MOD_DEBUG_PATH:-}" ]]; then
        echo "Deployed to:"
        echo "  ${MOD_DEBUG_PATH}"
    else
        echo "Deployed to: dist"
    fi
elif [[ "${MODE,,}" == "release" ]]; then
    echo "Release artefacts in: build/release/"
    echo "  SkyUI_SE.bsa"
    echo "  SkyUI_SE-<version>.zip"
fi
echo
