#[=======================================================================[.rst:
ImportToSWF
-----------

Generic ActionScript injection into SWF files.

Usage
^^^^^

Step 1: Before the SWF loop, call once:

  AS_GlobalAssemble_Init(
      AS_SOURCE_DIR <path>
  )

Step 2: Inside the SWF loop, call per SWF:

  Add_AS(
      TARGET_NAME <name>
      SWF_INPUT   <absolute/path/to/base.swf>
      SWF_OUTPUT  <absolute/path/to/output.swf>
      SOURCES     <file> [...]
      [FRAME_SOURCES <file> [...]]
  )

Step 3: After the loop, call once to finalize the global assemble target:

  AS_GlobalAssemble_Finalize()

#]=======================================================================]

if(NOT CMAKE_SCRIPT_MODE_FILE)

# Capture the path to THIS file at include-time so functions called later
# from CMakeLists.txt (like AS_GlobalAssemble_Finalize) know which script 
# to invoke at build-time.
set(_AS_IMPORT_MODULE_SCRIPT "${CMAKE_CURRENT_LIST_FILE}" CACHE INTERNAL "")

# ---------------------------------------------------------------------------
# Internal state (global properties)
# ---------------------------------------------------------------------------

define_property(GLOBAL PROPERTY _AS_SOURCE_DIR)
define_property(GLOBAL PROPERTY _AS_GLOBAL_STAGING)
define_property(GLOBAL PROPERTY _AS_ALL_SOURCES)
define_property(GLOBAL PROPERTY _AS_ALL_FRAME_SOURCES)

# ---------------------------------------------------------------------------
# AS_GlobalAssemble_Init
# ---------------------------------------------------------------------------
function(AS_GlobalAssemble_Init)
    cmake_parse_arguments(ARG "" "AS_SOURCE_DIR" "" ${ARGN})

    if(NOT ARG_AS_SOURCE_DIR)
        message(FATAL_ERROR "AS_GlobalAssemble_Init: AS_SOURCE_DIR is required.")
    endif()

    set_property(GLOBAL PROPERTY _AS_SOURCE_DIR      "${ARG_AS_SOURCE_DIR}")
    set_property(GLOBAL PROPERTY _AS_GLOBAL_STAGING  "${CMAKE_BINARY_DIR}/_AS_staging")
    set_property(GLOBAL PROPERTY _AS_ALL_SOURCES "")
    set_property(GLOBAL PROPERTY _AS_ALL_FRAME_SOURCES "")
endfunction()

# ---------------------------------------------------------------------------
# Add_AS
# ---------------------------------------------------------------------------
function(Add_AS)
    cmake_parse_arguments(ARG
        ""
        "TARGET_NAME;SWF_REL;SWF_INPUT;SWF_OUTPUT"
        "SOURCES;FRAME_SOURCES"
        ${ARGN}
    )

    if(NOT ARG_TARGET_NAME)
        message(FATAL_ERROR "Add_AS: TARGET_NAME is required.")
    endif()
    if(NOT ARG_SWF_REL)
        message(FATAL_ERROR "Add_AS: SWF_REL is required.")
    endif()
    if(NOT ARG_SWF_INPUT)
        message(FATAL_ERROR "Add_AS: SWF_INPUT is required.")
    endif()
    if(NOT ARG_SWF_OUTPUT)
        message(FATAL_ERROR "Add_AS: SWF_OUTPUT is required.")
    endif()
    if(NOT FFDEC_CLI)
        message(FATAL_ERROR "Add_AS: FFDEC_CLI is not set.")
    endif()

    get_property(_AS_SOURCE_DIR   GLOBAL PROPERTY _AS_SOURCE_DIR)
    get_property(_GLOBAL_STAGING  GLOBAL PROPERTY _AS_GLOBAL_STAGING)

    if(NOT _AS_SOURCE_DIR OR NOT _GLOBAL_STAGING)
        message(FATAL_ERROR "Add_AS: call AS_GlobalAssemble_Init() first.")
    endif()

    # Prepend source dir to relative paths
    set(_REAL_SOURCES "")
    foreach(_SRC ${ARG_SOURCES})
        if(IS_ABSOLUTE "${_SRC}")
            list(APPEND _REAL_SOURCES "${_SRC}")
        else()
            list(APPEND _REAL_SOURCES "${_AS_SOURCE_DIR}/${_SRC}")
        endif()
    endforeach()
    set(ARG_SOURCES ${_REAL_SOURCES})

    set(_REAL_FRAME_SOURCES "")
    foreach(_SRC ${ARG_FRAME_SOURCES})
        if(IS_ABSOLUTE "${_SRC}")
            list(APPEND _REAL_FRAME_SOURCES "${_SRC}")
        else()
            list(APPEND _REAL_FRAME_SOURCES "${_AS_SOURCE_DIR}/${_SRC}")
        endif()
    endforeach()
    set(ARG_FRAME_SOURCES ${_REAL_FRAME_SOURCES})

    set_property(GLOBAL APPEND PROPERTY _AS_ALL_SOURCES ${ARG_SOURCES})
    if(ARG_FRAME_SOURCES)
        set_property(GLOBAL APPEND PROPERTY _AS_ALL_FRAME_SOURCES ${ARG_FRAME_SOURCES})
    endif()

    add_custom_command(
        OUTPUT "${ARG_SWF_OUTPUT}"
        COMMAND "${CMAKE_COMMAND}" -E echo "[Build] ffdec -importScript ${ARG_SWF_REL}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${ARG_SWF_INPUT}" "${ARG_SWF_OUTPUT}"
        COMMAND "${FFDEC_CLI}"
            -config autoDeobfuscate=false,decompile=false
            -onerror abort
            -importScript "${ARG_SWF_OUTPUT}" "${ARG_SWF_OUTPUT}" "${_GLOBAL_STAGING}"
        DEPENDS
            "${ARG_SWF_INPUT}"
            ${ARG_SOURCES}
            ${ARG_FRAME_SOURCES}
        VERBATIM
    )

    add_custom_target("${ARG_TARGET_NAME}"
        DEPENDS "${ARG_SWF_OUTPUT}"
        SOURCES ${ARG_SOURCES} ${ARG_FRAME_SOURCES}
    )

    add_dependencies("${ARG_TARGET_NAME}" "ActionScript_Assemble")

    set("${ARG_TARGET_NAME}_OUTPUT" "${ARG_SWF_OUTPUT}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# AS_GlobalAssemble_Finalize
# ---------------------------------------------------------------------------
function(AS_GlobalAssemble_Finalize)
    get_property(_AS_SOURCE_DIR     GLOBAL PROPERTY _AS_SOURCE_DIR)
    get_property(_GLOBAL_STAGING    GLOBAL PROPERTY _AS_GLOBAL_STAGING)
    get_property(_ALL_SOURCES       GLOBAL PROPERTY _AS_ALL_SOURCES)
    get_property(_ALL_FRAME_SOURCES GLOBAL PROPERTY _AS_ALL_FRAME_SOURCES)

    list(REMOVE_DUPLICATES _ALL_SOURCES)
    if(_ALL_FRAME_SOURCES)
        list(REMOVE_DUPLICATES _ALL_FRAME_SOURCES)
    endif()

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
        BYPRODUCTS "${_GLOBAL_STAGING}/__Packages"
        COMMAND "${CMAKE_COMMAND}" -E echo "[Build] Assembling all ActionScript sources"
        COMMAND "${CMAKE_COMMAND}"
            "--log-level=WARNING"
            "-DSTAGING_DIR=${_GLOBAL_STAGING}"
            "-DSOURCES_FILE=${_SOURCES_FILE}"
            "-DFRAME_SOURCES_FILE=${_FRAME_SOURCES_FILE}"
            "-DAS_SOURCE_DIR=${_AS_SOURCE_DIR}"
            "-DPROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}"
            "-DPROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}"
            "-DGLOBAL_STAMP=${_GLOBAL_STAMP}"
            -P "${_AS_IMPORT_MODULE_SCRIPT}"
        DEPENDS ${_ALL_SOURCES} ${_ALL_FRAME_SOURCES} "${_AS_IMPORT_MODULE_SCRIPT}"
        VERBATIM
    )

    add_custom_target("ActionScript_Assemble"
        DEPENDS "${_GLOBAL_STAMP}"
    )
endfunction()

else() # CMAKE_SCRIPT_MODE_FILE

# ---------------------------------------------------------------------------
# Build-time Assembly Logic (merged from AssembleScripts.cmake)
# ---------------------------------------------------------------------------

file(MAKE_DIRECTORY "${STAGING_DIR}/__Packages")
file(STRINGS "${SOURCES_FILE}" SOURCES)

foreach(SRC ${SOURCES})
    file(RELATIVE_PATH REL "${AS_SOURCE_DIR}" "${SRC}")
    string(FIND "${REL}" "/" SLASH_POS)
    if(SLASH_POS EQUAL -1)
        continue()
    endif()
    math(EXPR AFTER "${SLASH_POS} + 1")
    string(SUBSTRING "${REL}" ${AFTER} -1 CLASSPATH)

    set(DST "${STAGING_DIR}/__Packages/${CLASSPATH}")
    if(NOT EXISTS "${SRC}")
        continue()
    endif()

    get_filename_component(DST_DIR "${DST}" DIRECTORY)
    file(MAKE_DIRECTORY "${DST_DIR}")
    file(COPY_FILE "${SRC}" "${DST}" ONLY_IF_DIFFERENT)
endforeach()

if(DEFINED FRAME_SOURCES_FILE AND EXISTS "${FRAME_SOURCES_FILE}")
    file(STRINGS "${FRAME_SOURCES_FILE}" FRAME_SOURCES)
    foreach(SRC ${FRAME_SOURCES})
        if(EXISTS "${SRC}")
            get_filename_component(FNAME "${SRC}" NAME)
            file(COPY_FILE "${SRC}" "${STAGING_DIR}/${FNAME}" ONLY_IF_DIFFERENT)
        endif()
    endforeach()
endif()

if(DEFINED GLOBAL_STAMP)
    file(TOUCH "${GLOBAL_STAMP}")
endif()

endif()
