#[=======================================================================[.rst:
PapyrusCustom
-------------

Compile Papyrus scripts using the russo-2025 "papyrus" compiler.
https://github.com/russo-2025/papyrus-compiler (V-lang native binary)

Drop-in alternative to BethesdaCMakeModules/Papyrus.cmake.
Used when tools/Papyrus/papyrus[.exe] is present; callers fall back to
the upstream Papyrus_Add() when it is not.

Compilation strategy: per-directory, not per-file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The compiler is invoked ONCE for the entire source directory:

  papyrus compile -i <source_dir> -o <output_dir> -h <header_dir> ...

Rationale:
  1. Cross-file dependencies (script inheritance) are resolved in a single
     compiler pass.  Per-file parallel invocations would require each
     process to re-parse every header, and would race if script B inherits
     script A and both compile simultaneously.
  2. The compiler is a native binary — process-spawn overhead is negligible.
  3. Built-in caching (omit -nocache) lets the compiler skip unchanged
     files internally on incremental runs, so the cost is proportional to
     what actually changed, not to the total number of scripts.

CMake dependency tracking:
  The stamp OUTPUT depends on all individual SOURCES (via DEPENDS).
  CMake/Ninja therefore skips the compilation step entirely when no .psc
  file has changed since the last successful build — the compiler is never
  invoked in that case.  When at least one .psc changes, the compiler runs
  once, processes the whole directory, skips cached-unchanged files, and
  writes only the changed .pex files.

CLI mapping vs PapyrusCompiler.exe
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  PapyrusCompiler.exe "File.psc"      papyrus compile
    -import="dir1;dir2"                 -i <source_dir>
    -output="Scripts/"                  -o <output_dir>
    -flags="TESV_Papyrus_Flags.flg"     -h <dir1> [-h <dir2> ...]
    [-quiet]                            [-silent]
    [-optimize]                         (built-in, flag not needed)

Usage
^^^^^

.. code-block:: cmake

  # Detects tools/Papyrus/papyrus.exe; downloads automatically if absent.
  PapyrusCustom_Find()          # sets PAPYRUS_CUSTOM_COMPILER in cache

  if(PAPYRUS_CUSTOM_COMPILER)
      PapyrusCustom_Add(
          "Papyrus"
          SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source/scripts"
          SOURCES    ${PAPYRUS_SOURCES}
          HEADERS
              "${CMAKE_CURRENT_SOURCE_DIR}/source/scripts"
              "${SkyrimSE_PATH}/Data/Source/Scripts"
          [VERBOSE]
          [ANONYMIZE]
      )
  else()
      Papyrus_Add("Papyrus" ...)
  endif()

After PapyrusCustom_Add, ``<target>_OUTPUT`` is set in the calling scope
with the list of expected .pex paths, matching the Papyrus_Add() convention.

#]=======================================================================]

# ---------------------------------------------------------------------------
# PapyrusCustom_Find
# ---------------------------------------------------------------------------
# Locates tools/Papyrus/papyrus.exe.  If not found, downloads and extracts
# the compiler automatically from the official GitHub release.
#
# After a successful download the binary lands in
#   <source_root>/tools/Papyrus/
# which is where find_program looks on every subsequent configure — so the
# download happens exactly once and survives build-directory wipes.
#
# Add  tools/Papyrus/  to .gitignore to keep it out of version control.
#
# Hash verification
# -----------------
# PAPYRUS_COMPILER_SHA256 can be set on the command line or in a toolchain
# file to enable integrity checking:
#
#   cmake --preset debug -DPAPYRUS_COMPILER_SHA256=<sha256-of-the-zip>
#
# To compute the hash after a manual download:
#   PowerShell:  Get-FileHash papyrus-compiler-windows.zip -Algorithm SHA256
#   CMD:         certutil -hashfile papyrus-compiler-windows.zip SHA256
#
# If the variable is empty (default) the download proceeds without
# hash verification — safe for local development, not recommended for CI.
# ---------------------------------------------------------------------------

set(_PAPYRUS_COMPILER_URL
    "https://github.com/russo-2025/papyrus-compiler/releases/download/2025.03.18/papyrus-compiler-windows.zip"
    CACHE STRING "Download URL for the community Papyrus compiler" FORCE
)
set(PAPYRUS_COMPILER_SHA256 ""
    CACHE STRING "Expected SHA256 of the Papyrus compiler ZIP (leave empty to skip verification)"
)
# The ZIP extracts as:  papyrus-compiler/
#                           papyrus.exe
#                           ...
# We extract into tools/ so the subfolder lands at tools/papyrus-compiler/.
# _PAPYRUS_INSTALL_DIR points at the subfolder where the binary lives.
set(_PAPYRUS_COMPILER_SUBDIR "papyrus-compiler")

# PapyrusCustom_Find is a FUNCTION, not a macro.
#
# Critical distinction:
#   macro : return() exits the CALLER's scope (e.g. CMakeLists.txt!) — BUG
#   function: return() exits only this function — correct
#
# find_program without NO_CACHE writes to the CMake cache (global scope),
# so the result is visible to the caller without any PARENT_SCOPE dance.
# The cache variable is unset (unset(CACHE{PAPYRUS_CUSTOM_COMPILER})) before
# each search so we re-probe on every configure — same behaviour as NO_CACHE
# but compatible with function scope.
function(PapyrusCustom_Find)
    # Skip download when Papyrus compilation is disabled (e.g. CI without
    # Skyrim install).  return() here is safe because this is a function.
    if(NOT SKYUI_ENABLE_PAPYRUS)
        message(STATUS "[SkyUI] Papyrus compilation disabled — skipping compiler detection.")
        return()
    endif()

    # Clear any stale cache entry so find_program actually searches on
    # every configure (equivalent to NO_CACHE, but cache-visible to callers).
    # unset(CACHE{VAR}) is the CMake 4.2 explicit cache-entry syntax.
    unset(CACHE{PAPYRUS_CUSTOM_COMPILER})

    find_program(PAPYRUS_CUSTOM_COMPILER
        NAMES papyrus papyrus.exe
        PATHS "${CMAKE_CURRENT_SOURCE_DIR}/tools/${_PAPYRUS_COMPILER_SUBDIR}"
        NO_DEFAULT_PATH
        DOC "Path to the community Papyrus compiler"
    )

    if(NOT PAPYRUS_CUSTOM_COMPILER)
        # Extract to tools/ so the archive subfolder papyrus-compiler/ lands
        # directly at tools/papyrus-compiler/ without extra nesting.
        set(_PAPYRUS_EXTRACT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/tools")
        set(_PAPYRUS_INSTALL_DIR "${_PAPYRUS_EXTRACT_DIR}/${_PAPYRUS_COMPILER_SUBDIR}")
        set(_PAPYRUS_ZIP         "${CMAKE_CURRENT_BINARY_DIR}/download/papyrus-compiler-windows.zip")

        message(STATUS
            "[SkyUI] Papyrus compiler not found -- downloading from GitHub...")

        file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/download")

        # Build the optional EXPECTED_HASH argument only when a hash is provided.
        set(_HASH_ARG "")
        if(PAPYRUS_COMPILER_SHA256)
            set(_HASH_ARG EXPECTED_HASH "SHA256=EBB5B96545D9E296352BED86BC6665551185A2867E926AF8FC0EA87026632704")
        else()
            message(WARNING
                "[SkyUI] PAPYRUS_COMPILER_SHA256 is not set — "
                "downloading without integrity check. "
                "Set -DPAPYRUS_COMPILER_SHA256=<hash> to enable verification.")
        endif()

        file(DOWNLOAD
            "${_PAPYRUS_COMPILER_URL}"
            "${_PAPYRUS_ZIP}"
            ${_HASH_ARG}
            SHOW_PROGRESS
            STATUS _DOWNLOAD_STATUS
        )

        list(GET _DOWNLOAD_STATUS 0 _DOWNLOAD_ERROR_CODE)
        if(_DOWNLOAD_ERROR_CODE)
            list(GET _DOWNLOAD_STATUS 1 _DOWNLOAD_ERROR_MSG)
            message(FATAL_ERROR
                "[SkyUI] Failed to download Papyrus compiler: ${_DOWNLOAD_ERROR_MSG}\n"
                "URL: ${_PAPYRUS_COMPILER_URL}\n"
                "Alternatively, download manually and extract to: ${_PAPYRUS_INSTALL_DIR}")
        endif()

        message(STATUS "[SkyUI] Extracting to ${_PAPYRUS_EXTRACT_DIR} ...")
        file(ARCHIVE_EXTRACT
            INPUT       "${_PAPYRUS_ZIP}"
            DESTINATION "${_PAPYRUS_EXTRACT_DIR}"
        )
        # Result: ${_PAPYRUS_EXTRACT_DIR}/papyrus-compiler/papyrus.exe

        # Re-run find_program after extraction to resolve the full path.
        unset(CACHE{PAPYRUS_CUSTOM_COMPILER})
        find_program(PAPYRUS_CUSTOM_COMPILER
            NAMES papyrus papyrus.exe
            PATHS "${_PAPYRUS_INSTALL_DIR}"
            NO_DEFAULT_PATH
        )
        # _PAPYRUS_INSTALL_DIR = tools/papyrus-compiler/

        if(NOT PAPYRUS_CUSTOM_COMPILER)
            message(FATAL_ERROR
                "[SkyUI] Papyrus compiler extracted but binary not found in "
                "${_PAPYRUS_INSTALL_DIR}.\n"
                "Check the archive layout at ${_PAPYRUS_COMPILER_URL}")
        endif()

        message(STATUS "[SkyUI] Papyrus compiler : ${PAPYRUS_CUSTOM_COMPILER} (downloaded)")
    else()
        message(STATUS "[SkyUI] Papyrus compiler : ${PAPYRUS_CUSTOM_COMPILER}")
    endif()
endfunction()

# ---------------------------------------------------------------------------
# PapyrusCustom_Add
# ---------------------------------------------------------------------------
# Parameters:
#   <target>              Name for the CMake custom target (e.g. "Papyrus")
#   SOURCE_DIR <dir>      Directory passed to  -i  (all .psc compiled at once)
#   SOURCES    <...>      Individual .psc paths — used ONLY for:
#                           • CMake DEPENDS (change detection)
#                           • computing the expected <target>_OUTPUT list
#                           • source_group() in the IDE
#   HEADERS    <...>      Directories passed as repeated  -h <dir>  arguments.
#                         Typically: SOURCE_DIR first, then Skyrim vanilla dir.
#   [VERBOSE]             Show compiler output. Default: suppress with -silent.
#   [ANONYMIZE]           Run AFKPexAnon on the output directory afterwards.
# ---------------------------------------------------------------------------
function(PapyrusCustom_Add PAPYRUS_TARGET)
    cmake_parse_arguments(P
        "VERBOSE;ANONYMIZE"
        "SOURCE_DIR"
        "SOURCES;HEADERS"
        ${ARGN}
    )

    if(NOT PAPYRUS_CUSTOM_COMPILER)
        message(FATAL_ERROR
            "PapyrusCustom_Add: PAPYRUS_CUSTOM_COMPILER is not set. "
            "Call PapyrusCustom_Find() first.")
    endif()
    if(NOT P_SOURCE_DIR)
        message(FATAL_ERROR
            "PapyrusCustom_Add: SOURCE_DIR is required.")
    endif()
    if(NOT P_SOURCES)
        message(FATAL_ERROR
            "PapyrusCustom_Add: SOURCES must not be empty "
            "(needed for dependency tracking and output list).")
    endif()

    set(_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/Scripts")
    file(MAKE_DIRECTORY "${_OUTPUT_DIR}")

    # Build  -h <dir>  argument list — one flag per header directory.
    set(_H_ARGS "")
    foreach(_HDR IN LISTS P_HEADERS)
        list(APPEND _H_ARGS "-h" "${_HDR}")
    endforeach()

    set(_SILENT_ARG "")
    if(NOT P_VERBOSE)
        set(_SILENT_ARG "-silent")
    endif()

    # ---- Compute expected output list -------------------------------------
    # The compiler writes <stem>.pex for every <stem>.psc it compiles.
    # We derive this list from SOURCES so downstream targets (Deploy, BSA)
    # know which files to expect.
    set(_PAPYRUS_OUTPUT "")
    foreach(_SRC IN LISTS P_SOURCES)
        cmake_path(GET _SRC STEM LAST_ONLY _STEM)
        list(APPEND _PAPYRUS_OUTPUT "${_OUTPUT_DIR}/${_STEM}.pex")
    endforeach()

    # ---- Single stamp file ------------------------------------------------
    set(_STAMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/_Papyrus")
    set(_STAMP     "${_STAMP_DIR}/${PAPYRUS_TARGET}.stamp")

    # ---- Single compilation command ---------------------------------------
    #
    # -i <SOURCE_DIR>  : compile entire directory in one process
    # -o <OUTPUT_DIR>  : all .pex files go here
    # -h <dir> ...     : header/import directories (one -h flag per dir)
    # (no -nocache)    : built-in cache skips unchanged files on re-runs
    #
    # DEPENDS lists every .psc individually so Ninja/CMake detects changes
    # at the file level and skips this command when nothing has changed.
    #
    # BYPRODUCTS lists the .pex files so that `cmake --build --target clean`
    # removes them, and so Ninja can correctly detect missing outputs.

    add_custom_command(
        OUTPUT "${_STAMP}"
        BYPRODUCTS ${_PAPYRUS_OUTPUT}
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${_STAMP_DIR}"
        COMMAND "${PAPYRUS_CUSTOM_COMPILER}"
                compile
                -i  "${P_SOURCE_DIR}"
                -o  "${_OUTPUT_DIR}"
                ${_H_ARGS}
                ${_SILENT_ARG}
        COMMAND "${CMAKE_COMMAND}" -E touch "${_STAMP}"
        DEPENDS ${P_SOURCES}
        COMMENT "Compiling Papyrus scripts (${P_SOURCE_DIR})"
        VERBATIM
    )

    # ---- Optional anonymisation -------------------------------------------
    if(P_ANONYMIZE)
        find_program(PEXANON_COMMAND "AFKPexAnon"
            PATHS "tools/AFKPexAnon"
            NO_CACHE
        )

        if(NOT PEXANON_COMMAND)
            message(WARNING
                "PapyrusCustom_Add: ANONYMIZE requested but AFKPexAnon "
                "not found in tools/AFKPexAnon/. Skipping.")
        else()
            add_custom_command(
                OUTPUT  "${_STAMP}"
                COMMAND "${PEXANON_COMMAND}" -s "${_OUTPUT_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E touch "${_STAMP}"
                VERBATIM
                APPEND
            )
        endif()
    endif()

    # ---- CMake target -------------------------------------------------------

    add_custom_target("${PAPYRUS_TARGET}"
        ALL
        DEPENDS "${_STAMP}"
        SOURCES ${P_SOURCES}
    )

    source_group("Scripts" FILES ${P_SOURCES})

    set("${PAPYRUS_TARGET}_OUTPUT" "${_PAPYRUS_OUTPUT}" PARENT_SCOPE)
endfunction()