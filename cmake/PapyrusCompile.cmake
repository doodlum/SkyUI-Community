# cmake/PapyrusCompile.cmake
#
# Script wrapper for the Papyrus compiler called via cmake -P.
# Captures stdout+stderr from the compiler and re-emits them cleanly,
# so that both Ninja and MSBuild show human-readable errors instead of
# truncated/mangled output.
#
# Parameters (passed via -D):
#   COMPILER     — path to papyrus.exe
#   SOURCE_DIR   — directory with .psc source files  (-i)
#   OUTPUT_DIR   — directory for .pex output files   (-o)
#   H_ARGS_STR   — @@-separated list of "-h <dir>" pairs
#                  (list separator chosen to avoid CMake semicolon splitting)
#
# Usage (from PapyrusCustom.cmake):
#   cmake -DCOMPILER=... -DSOURCE_DIR=... -DOUTPUT_DIR=... -DH_ARGS_STR=... \
#         -P cmake/PapyrusCompile.cmake

cmake_minimum_required(VERSION 4.2)

# ── Validate inputs ──────────────────────────────────────────────────────────
foreach(_var COMPILER SOURCE_DIR OUTPUT_DIR)
    if(NOT ${_var})
        message(FATAL_ERROR "PapyrusCompile.cmake: -D${_var} is required")
    endif()
endforeach()

if(NOT EXISTS "${COMPILER}")
    message(FATAL_ERROR
        "PapyrusCompile.cmake: compiler not found:\n"
        "  ${COMPILER}")
endif()

if(NOT IS_DIRECTORY "${SOURCE_DIR}")
    message(FATAL_ERROR
        "PapyrusCompile.cmake: SOURCE_DIR does not exist:\n"
        "  ${SOURCE_DIR}")
endif()

# ── Reconstruct -h <dir> argument list ──────────────────────────────────────
# H_ARGS_STR is "@@"-joined to survive CMake's semicolon list-splitting.
# Example input:  "-h@@C:/path/a@@-h@@C:/path/b"
set(_H_ARGS)
if(H_ARGS_STR)
    string(REPLACE "@@" ";" _H_ARGS_LIST "${H_ARGS_STR}")
    set(_H_ARGS ${_H_ARGS_LIST})
endif()

# ── Run the compiler ─────────────────────────────────────────────────────────
execute_process(
    COMMAND "${COMPILER}"
            compile
            -i  "${SOURCE_DIR}"
            -o  "${OUTPUT_DIR}"
            ${_H_ARGS}
    OUTPUT_VARIABLE _PAPYRUS_OUT
    ERROR_VARIABLE  _PAPYRUS_ERR
    RESULT_VARIABLE _PAPYRUS_RC
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
)

# ── Always show compiler output so non-error lines (e.g. "compiled 42 files")
#    appear in verbose builds.  message(STATUS) goes to stdout without
#    the CMake log-level prefix that would confuse MSBuild's output parser.
if(_PAPYRUS_OUT)
    message(STATUS "${_PAPYRUS_OUT}")
endif()

# ── On failure: print everything and abort ───────────────────────────────────
if(NOT _PAPYRUS_RC EQUAL 0)
    # Build a readable header so the error is easy to spot in long build logs.
    string(REPEAT "─" 64 _HR)

    # Collect the useful output: prefer stderr (errors), fall back to stdout.
    set(_DIAG "")
    if(_PAPYRUS_ERR)
        string(APPEND _DIAG "${_PAPYRUS_ERR}\n")
    endif()
    if(_PAPYRUS_OUT AND NOT _PAPYRUS_OUT STREQUAL _PAPYRUS_ERR)
        string(APPEND _DIAG "${_PAPYRUS_OUT}\n")
    endif()

    message(FATAL_ERROR
        "\n${_HR}\n"
        " Papyrus compilation FAILED  (exit code ${_PAPYRUS_RC})\n"
        " Source dir : ${SOURCE_DIR}\n"
        " Output dir : ${OUTPUT_DIR}\n"
        "${_HR}\n"
        "${_DIAG}"
        "${_HR}\n"
        " Tip: fix the errors above, then re-run:\n"
        "   cmake --build --preset debug\n"
        "${_HR}"
    )
endif()