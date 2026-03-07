#[=======================================================================[.rst:
ActionScript
------------

Compile and inject ActionScript sources into SWF files using FFDec CLI.

The function assumes FFDec CLI has already been located and stored in the
cache variable ``FFDEC_CLI`` before this module is used.

Usage
^^^^^

.. code-block:: cmake

  SkyUI_AS_Add(
      TARGET_NAME  <n>
      SWF_REL      <relative-swf-path>
      SOURCES      <file> [...]
      [FRAME_SOURCES <file> [...]])

After the call, ``${TARGET_NAME}_OUTPUT`` is set in the calling scope to
the absolute path of the compiled SWF in the build directory.

Parameters
^^^^^^^^^^

``TARGET_NAME``
  CMake custom-target name.  Convention: ``AS_<swf_stem>``.

``SWF_REL``
  Path to the SWF relative to ``data/interface/``.
  Example: ``quest_journal.swf``, ``mapMenu/map_menu.swf``

``SOURCES``
  One or more ActionScript source files (.as).
  Any change to these files triggers a rebuild of this SWF only.

``FRAME_SOURCES``
  Optional frame / DoInitAction scripts staged at the staging root
  rather than under ``__Packages/``.

How incremental builds work
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Each SWF compilation is split into two custom-command steps that are
tracked independently by CMake's dependency graph:

Step 1 — Assemble
  ``cmake/AssembleScripts.cmake`` copies the .as files into the
  ``__Packages/`` staging tree that FFDec expects.
  A stamp file ``<staging>/.assembled.stamp`` is the declared OUTPUT,
  so CMake can compare it against source file timestamps.
  DEPENDS lists every .as source explicitly → fine-grained, per-SWF
  invalidation.  Touching one SWF's sources never invalidates another.

Step 2 — Inject
  Copies the pristine source SWF into the build tree (non-destructive;
  the repository copy is never modified) then calls
  ``ffdec-cli -importScript`` to inject the staged scripts.
  DEPENDS the stamp from step 1 and the original .swf, so it only
  runs when either the source SWF or the assembled scripts changed.

#]=======================================================================]

function(SkyUI_AS_Add)
    # ---- Argument parsing ------------------------------------------------
    cmake_parse_arguments(ARG
        ""
        "TARGET_NAME;SWF_REL"
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
        message(FATAL_ERROR
            "SkyUI_AS_Add: FFDEC_CLI cache variable is not set. "
            "Locate ffdec-cli before calling this function."
        )
    endif()

    # ---- Paths -----------------------------------------------------------

    # Source SWF — lives in the repository; NEVER modified in-place.
    set(SWF_INPUT  "${CMAKE_CURRENT_SOURCE_DIR}/data/interface/${ARG_SWF_REL}")

    # Output SWF — lives in the build tree under interface/, mirroring data/interface/.
    set(SWF_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/interface/${ARG_SWF_REL}")

    get_filename_component(SWF_OUTPUT_DIR "${SWF_OUTPUT}" DIRECTORY)
    file(MAKE_DIRECTORY "${SWF_OUTPUT_DIR}")

    # Filesystem-safe variable prefix derived from the relative SWF path.
    # e.g.  "mapMenu/map_menu.swf"  →  "mapMenu_map_menu"
    get_filename_component(SWF_NAME_WE   "${ARG_SWF_REL}" NAME_WE)
    get_filename_component(SWF_DIR_PART  "${ARG_SWF_REL}" DIRECTORY)

    if(SWF_DIR_PART)
        string(REPLACE "/" "_" _VAR_PREFIX "${SWF_DIR_PART}/${SWF_NAME_WE}")
    else()
        set(_VAR_PREFIX "${SWF_NAME_WE}")
    endif()

    set(_AS_SOURCE_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/source/actionscript")
    set(_AS_STAGING     "${CMAKE_CURRENT_BINARY_DIR}/_AS_staging/${_VAR_PREFIX}")
    set(_ASSEMBLE_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/AssembleScripts.cmake")

    # Source-list files are written at configure time so AssembleScripts.cmake
    # can read them at build time with file(STRINGS …).
    set(_SOURCES_FILE "${CMAKE_CURRENT_BINARY_DIR}/_AS_staging/${_VAR_PREFIX}_sources.txt")
    list(JOIN ARG_SOURCES "\n" _SOURCES_CONTENT)
    file(WRITE "${_SOURCES_FILE}" "${_SOURCES_CONTENT}")

    set(_FRAME_SOURCES_FILE "")
    if(ARG_FRAME_SOURCES)
        set(_FRAME_SOURCES_FILE
            "${CMAKE_CURRENT_BINARY_DIR}/_AS_staging/${_VAR_PREFIX}_frame_sources.txt")
        list(JOIN ARG_FRAME_SOURCES "\n" _FRAME_CONTENT)
        file(WRITE "${_FRAME_SOURCES_FILE}" "${_FRAME_CONTENT}")
    endif()

    # ---- Step 1: Assemble -----------------------------------------------

    set(_ASSEMBLE_STAMP "${_AS_STAGING}/.assembled.stamp")

    add_custom_command(
        OUTPUT "${_ASSEMBLE_STAMP}"
        COMMAND "${CMAKE_COMMAND}"
            "-DSTAGING_DIR=${_AS_STAGING}"
            "-DSOURCES_FILE=${_SOURCES_FILE}"
            "-DFRAME_SOURCES_FILE=${_FRAME_SOURCES_FILE}"
            "-DAS_SOURCE_DIR=${_AS_SOURCE_DIR}"
            "-DPROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}"
            "-DPROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}"
            -P "${_ASSEMBLE_SCRIPT}"
        COMMAND "${CMAKE_COMMAND}" -E touch "${_ASSEMBLE_STAMP}"
        # Every .as source is an explicit dependency for fine-grained rebuild.
        DEPENDS
            ${ARG_SOURCES}
            ${ARG_FRAME_SOURCES}
            "${_ASSEMBLE_SCRIPT}"
        COMMENT "Assembling ActionScript sources for ${ARG_SWF_REL}"
        VERBATIM
    )

    # ---- Step 2: Inject --------------------------------------------------

    add_custom_command(
        OUTPUT "${SWF_OUTPUT}"
        # Copy the pristine source SWF into the build tree first.
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${SWF_INPUT}" "${SWF_OUTPUT}"
        # Inject the assembled scripts into the build-tree copy.
        COMMAND "${FFDEC_CLI}"
            -importScript "${SWF_OUTPUT}" "${SWF_OUTPUT}" "${_AS_STAGING}"
        DEPENDS
            "${SWF_INPUT}"
            "${_ASSEMBLE_STAMP}"
        COMMENT "Injecting ActionScript into ${ARG_SWF_REL}"
        VERBATIM
    )

    # ---- Target ----------------------------------------------------------

    add_custom_target("${ARG_TARGET_NAME}"
        DEPENDS "${SWF_OUTPUT}"
        SOURCES ${ARG_SOURCES} ${ARG_FRAME_SOURCES}
    )

    source_group("ActionScript\\${_VAR_PREFIX}" FILES ${ARG_SOURCES} ${ARG_FRAME_SOURCES})

    # Expose the compiled SWF path to the calling scope.
    set("${ARG_TARGET_NAME}_OUTPUT" "${SWF_OUTPUT}" PARENT_SCOPE)
endfunction()