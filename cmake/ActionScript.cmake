#[=======================================================================[.rst:
ActionScript
------------

Two-phase ActionScript compilation: one global assemble, per-SWF inject.

Architecture
^^^^^^^^^^^^

Phase 1 — Global Assemble (one cmake -P process for all SWFs)
  A single ``cmake/AssembleScripts.cmake`` invocation copies ALL ActionScript
  sources from ALL SWFs into one shared staging tree:

    ${CMAKE_BINARY_DIR}/_AS_staging/__Packages/

  This target (``ActionScript_Assemble``) depends on every .as file across
  the entire project. It runs once when any source changes.

Phase 2 — Per-SWF Inject (parallel, fine-grained)
  Each SWF has its own ``add_custom_command`` whose DEPENDS list contains
  that SWF's specific .as source files plus the original .swf.

  This means CMake rebuilds a SWF if and only if:
    - one of its own .as sources changed, OR
    - the base .swf changed

  Changing Quest_Journal.as → only quest_journal.swf reinjects.
  Other SWFs are untouched.

  All inject steps are independent and run in parallel under Ninja.

Why inject depends on sources directly, not on the assemble stamp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  If inject depended on the global stamp, any .as change anywhere would
  invalidate all 30 inject steps — the opposite of what we want.

  Instead:
    - The assemble target is an ORDER-ONLY dependency (via add_dependencies)
      so it always runs before any inject, but does not cause inject to
      re-run unless the inject's own DEPENDS are stale.
    - The inject command lists its specific .as sources in DEPENDS so CMake
      can track exactly which SWF is affected by a given file change.

Shared classes
^^^^^^^^^^^^^^
  If two SWFs share a class (e.g. Common/skyui/defines/Input.as) and that
  file appears in both their SOURCES lists, both DEPENDS lists contain it.
  Changing it correctly invalidates both SWF inject steps.

Usage
^^^^^

Step 1: Before the SWF loop, call once:

  SkyUI_AS_GlobalAssemble_Init(
      AS_SOURCE_DIR    <path>
      ASSEMBLE_SCRIPT  <path/AssembleScripts.cmake>
  )

Step 2: Inside the SWF loop, call per SWF:

  SkyUI_AS_Add(
      TARGET_NAME  AS_<name>
      SWF_REL      <relative/path.swf>
      SOURCES      <file> [...]
      [FRAME_SOURCES <file> [...]]
  )

Step 3: After the loop, call once to finalize the global assemble target:

  SkyUI_AS_GlobalAssemble_Finalize()

After SkyUI_AS_Add, ``${TARGET_NAME}_OUTPUT`` is set in the calling scope.

#]=======================================================================]

# ---------------------------------------------------------------------------
# Internal state (global properties, visible across function boundaries)
# ---------------------------------------------------------------------------

define_property(GLOBAL PROPERTY _SKYUI_AS_SOURCE_DIR)
define_property(GLOBAL PROPERTY _SKYUI_AS_ASSEMBLE_SCRIPT)
define_property(GLOBAL PROPERTY _SKYUI_AS_GLOBAL_STAGING)
define_property(GLOBAL PROPERTY _SKYUI_AS_ALL_SOURCES)   # accumulates across calls
define_property(GLOBAL PROPERTY _SKYUI_AS_ALL_FRAME_SOURCES)

# ---------------------------------------------------------------------------
# SkyUI_AS_GlobalAssemble_Init
# ---------------------------------------------------------------------------
# Call ONCE before the SWF discovery loop.
# ---------------------------------------------------------------------------
function(SkyUI_AS_GlobalAssemble_Init)
    cmake_parse_arguments(ARG "" "AS_SOURCE_DIR;ASSEMBLE_SCRIPT" "" ${ARGN})

    if(NOT ARG_AS_SOURCE_DIR)
        message(FATAL_ERROR "SkyUI_AS_GlobalAssemble_Init: AS_SOURCE_DIR is required.")
    endif()
    if(NOT ARG_ASSEMBLE_SCRIPT)
        message(FATAL_ERROR "SkyUI_AS_GlobalAssemble_Init: ASSEMBLE_SCRIPT is required.")
    endif()

    set_property(GLOBAL PROPERTY _SKYUI_AS_SOURCE_DIR      "${ARG_AS_SOURCE_DIR}")
    set_property(GLOBAL PROPERTY _SKYUI_AS_ASSEMBLE_SCRIPT "${ARG_ASSEMBLE_SCRIPT}")
    set_property(GLOBAL PROPERTY _SKYUI_AS_GLOBAL_STAGING
        "${CMAKE_BINARY_DIR}/_AS_staging")
    set_property(GLOBAL PROPERTY _SKYUI_AS_ALL_SOURCES "")
    set_property(GLOBAL PROPERTY _SKYUI_AS_ALL_FRAME_SOURCES "")
endfunction()

# ---------------------------------------------------------------------------
# SkyUI_AS_Add
# ---------------------------------------------------------------------------
# Call once per SWF inside the discovery loop.
# ---------------------------------------------------------------------------
function(SkyUI_AS_Add)
    cmake_parse_arguments(ARG
        ""
        "TARGET_NAME;SWF_REL;SWF_BASE_DIR"
        "SOURCES;FRAME_SOURCES"
        ${ARGN}
    )

    if(NOT ARG_TARGET_NAME)
        message(FATAL_ERROR "SkyUI_AS_Add: TARGET_NAME is required.")
    endif()
    if(NOT ARG_SWF_REL)
        message(FATAL_ERROR "SkyUI_AS_Add: SWF_REL is required.")
    endif()
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "SkyUI_AS_Add: SOURCES must contain at least one file.")
    endif()
    if(NOT FFDEC_CLI)
        message(FATAL_ERROR "SkyUI_AS_Add: FFDEC_CLI is not set.")
    endif()

    if(NOT ARG_SWF_BASE_DIR)
        set(ARG_SWF_BASE_DIR "data/interface")
    endif()

    # Retrieve global state
    get_property(_AS_SOURCE_DIR   GLOBAL PROPERTY _SKYUI_AS_SOURCE_DIR)
    get_property(_GLOBAL_STAGING  GLOBAL PROPERTY _SKYUI_AS_GLOBAL_STAGING)

    if(NOT _AS_SOURCE_DIR OR NOT _GLOBAL_STAGING)
        message(FATAL_ERROR
            "SkyUI_AS_Add: call SkyUI_AS_GlobalAssemble_Init() first.")
    endif()

    # Accumulate sources into global lists
    set_property(GLOBAL APPEND PROPERTY _SKYUI_AS_ALL_SOURCES ${ARG_SOURCES})
    if(ARG_FRAME_SOURCES)
        set_property(GLOBAL APPEND PROPERTY
            _SKYUI_AS_ALL_FRAME_SOURCES ${ARG_FRAME_SOURCES})
    endif()

    # ---- Inject step -------------------------------------------------------
    # OUTPUT: compiled SWF in the build tree
    # DEPENDS: this SWF's own .as sources + the original .swf
    #
    # NOTE: no dependency on the global stamp here. Instead, we use
    # add_dependencies() (target-level) below to enforce ordering.
    # This is the key to per-SWF incremental granularity.

    set(_SWF_INPUT  "${CMAKE_CURRENT_SOURCE_DIR}/${ARG_SWF_BASE_DIR}/${ARG_SWF_REL}")
    set(_SWF_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/interface/${ARG_SWF_REL}")

    add_custom_command(
        OUTPUT "${_SWF_OUTPUT}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${_SWF_INPUT}" "${_SWF_OUTPUT}"
        COMMAND "${FFDEC_CLI}"
            -config autoDeobfuscate=false,decompile=false
            -onerror abort
            -importScript "${_SWF_OUTPUT}" "${_SWF_OUTPUT}" "${_GLOBAL_STAGING}"
        # Fine-grained: only this SWF's sources + the base SWF file.
        # Changing quest_journal.as does NOT invalidate bartermenu.swf.
        DEPENDS
            "${_SWF_INPUT}"
            ${ARG_SOURCES}
            ${ARG_FRAME_SOURCES}
        COMMENT "Injecting ActionScript into ${ARG_SWF_REL}"
        VERBATIM
    )

    add_custom_target("${ARG_TARGET_NAME}"
        DEPENDS "${_SWF_OUTPUT}"
        SOURCES ${ARG_SOURCES} ${ARG_FRAME_SOURCES}
    )

    # ORDER-ONLY: assemble must finish before inject runs, but a change to
    # the assemble stamp does NOT force this inject to re-run.
    add_dependencies("${ARG_TARGET_NAME}" "ActionScript_Assemble")

    # Filesystem-safe source group name
    get_filename_component(_SWF_NAME_WE  "${ARG_SWF_REL}" NAME_WE)
    get_filename_component(_SWF_DIR_PART "${ARG_SWF_REL}" DIRECTORY)
    if(_SWF_DIR_PART)
        string(REPLACE "/" "_" _VAR_PREFIX "${_SWF_DIR_PART}/${_SWF_NAME_WE}")
    else()
        set(_VAR_PREFIX "${_SWF_NAME_WE}")
    endif()
    source_group("ActionScript\\${_VAR_PREFIX}" FILES ${ARG_SOURCES} ${ARG_FRAME_SOURCES})

    set("${ARG_TARGET_NAME}_OUTPUT" "${_SWF_OUTPUT}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# SkyUI_AS_GlobalAssemble_Finalize
# ---------------------------------------------------------------------------
# Call ONCE after the SWF discovery loop.
# Creates the ActionScript_Assemble target with all accumulated sources.
# ---------------------------------------------------------------------------
function(SkyUI_AS_GlobalAssemble_Finalize)
    get_property(_AS_SOURCE_DIR     GLOBAL PROPERTY _SKYUI_AS_SOURCE_DIR)
    get_property(_ASSEMBLE_SCRIPT   GLOBAL PROPERTY _SKYUI_AS_ASSEMBLE_SCRIPT)
    get_property(_GLOBAL_STAGING    GLOBAL PROPERTY _SKYUI_AS_GLOBAL_STAGING)
    get_property(_ALL_SOURCES       GLOBAL PROPERTY _SKYUI_AS_ALL_SOURCES)
    get_property(_ALL_FRAME_SOURCES GLOBAL PROPERTY _SKYUI_AS_ALL_FRAME_SOURCES)

    # Deduplicate: shared classes appear in multiple SWF source lists.
    list(REMOVE_DUPLICATES _ALL_SOURCES)
    if(_ALL_FRAME_SOURCES)
        list(REMOVE_DUPLICATES _ALL_FRAME_SOURCES)
    endif()

    # Write source-list files at configure time for AssembleScripts.cmake
    set(_SOURCES_FILE "${_GLOBAL_STAGING}/all_sources.txt")
    list(JOIN _ALL_SOURCES "\n" _SOURCES_CONTENT)
    file(MAKE_DIRECTORY "${_GLOBAL_STAGING}")
    file(WRITE "${_SOURCES_FILE}" "${_SOURCES_CONTENT}")

    set(_FRAME_SOURCES_FILE "")
    if(_ALL_FRAME_SOURCES)
        set(_FRAME_SOURCES_FILE "${_GLOBAL_STAGING}/all_frame_sources.txt")
        list(JOIN _ALL_FRAME_SOURCES "\n" _FRAME_CONTENT)
        file(WRITE "${_FRAME_SOURCES_FILE}" "${_FRAME_CONTENT}")
    endif()

    set(_GLOBAL_STAMP "${_GLOBAL_STAGING}/.assembled.stamp")

    add_custom_command(
        OUTPUT "${_GLOBAL_STAMP}"
        # Declare the staging tree so `cmake --build --target clean` removes it.
        BYPRODUCTS "${_GLOBAL_STAGING}/__Packages"
        COMMAND "${CMAKE_COMMAND}"
            "-DSTAGING_DIR=${_GLOBAL_STAGING}"
            "-DSOURCES_FILE=${_SOURCES_FILE}"
            "-DFRAME_SOURCES_FILE=${_FRAME_SOURCES_FILE}"
            "-DAS_SOURCE_DIR=${_AS_SOURCE_DIR}"
            "-DPROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}"
            "-DPROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}"
            -P "${_ASSEMBLE_SCRIPT}"
        COMMAND "${CMAKE_COMMAND}" -E touch "${_GLOBAL_STAMP}"
        # Depends on ALL sources: any .as change reruns assemble.
        DEPENDS ${_ALL_SOURCES} ${_ALL_FRAME_SOURCES} "${_ASSEMBLE_SCRIPT}"
        COMMENT "Assembling all ActionScript sources"
        VERBATIM
    )

    add_custom_target("ActionScript_Assemble"
        DEPENDS "${_GLOBAL_STAMP}"
    )
endfunction()