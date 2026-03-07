cmake_minimum_required(VERSION 3.24)

project(
    SkyUI
    VERSION 6.0
    LANGUAGES NONE
)

# ==============================================================================
# § 1  Build Configuration
# ==============================================================================
# Supported values for CMAKE_BUILD_TYPE: Debug | Release
#
# Debug   -> no BSA, no ZIP; compiled files are written directly into the
#             directory pointed to by MOD_DEBUG_OUTPUT_DIR.
# Release -> full pipeline: compile -> BSA -> ZIP.
# ==============================================================================

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release"
        CACHE STRING "Build configuration (Debug or Release)" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release")
endif()

string(TOUPPER "${CMAKE_BUILD_TYPE}" _BUILD_TYPE_UPPER)

if(_BUILD_TYPE_UPPER STREQUAL "DEBUG")
    set(IS_DEBUG_BUILD TRUE)
elseif(_BUILD_TYPE_UPPER STREQUAL "RELEASE")
    set(IS_DEBUG_BUILD FALSE)
else()
    message(FATAL_ERROR
        "Unsupported CMAKE_BUILD_TYPE '${CMAKE_BUILD_TYPE}'. Use 'Debug' or 'Release'.")
endif()

message(STATUS "[SkyUI] Build type : ${CMAKE_BUILD_TYPE}")

if(IS_DEBUG_BUILD)
    if(NOT DEFINED MOD_DEBUG_OUTPUT_DIR OR MOD_DEBUG_OUTPUT_DIR STREQUAL "")
        set(MOD_DEBUG_OUTPUT_DIR "${CMAKE_BINARY_DIR}/data"
            CACHE PATH "Debug output directory (Skyrim Data or MO2 mod folder)" FORCE)
    endif()
    message(STATUS "[SkyUI] Debug output : ${MOD_DEBUG_OUTPUT_DIR}")
endif()

# ==============================================================================
# § 2  Module Paths
# ==============================================================================

list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/external/BethesdaCMakeModules/Modules"
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
)

include(Papyrus)
include(BSArchive)
include(ActionScript)

# ==============================================================================
# § 3  FFDec CLI Detection
# ==============================================================================

find_program(FFDEC_CLI
    NAMES ffdec-cli ffdec-cli.exe
    PATHS "${CMAKE_CURRENT_SOURCE_DIR}/tools/FFDec"
    NO_DEFAULT_PATH
)
if(NOT FFDEC_CLI)
    find_program(FFDEC_CLI NAMES ffdec-cli ffdec-cli.exe)
endif()

if(FFDEC_CLI)
    message(STATUS "[SkyUI] FFDec CLI    : ${FFDEC_CLI}")
else()
    message(WARNING
        "[SkyUI] FFDec CLI not found. ActionScript compilation will be skipped.")
endif()

# ==============================================================================
# § 4  Papyrus Scripts
# ==============================================================================

file(GLOB PAPYRUS_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/source/scripts/*.psc")

if(PAPYRUS_SOURCES)
    Papyrus_Add(
        "Papyrus"
        GAME "${SkyrimSE_PATH}"
        MODE SkyrimSE
        IMPORTS
            "${CMAKE_CURRENT_SOURCE_DIR}/source/scripts"
            "${SkyrimSE_PATH}/Data/Scripts/Source"
            "${SkyrimSE_PATH}/Data/Source/Scripts"
        SOURCES ${PAPYRUS_SOURCES}
        # OPTIMIZE
        ANONYMIZE
        SKIP_DEFAULT_IMPORTS
    )
else()
    message(STATUS "[SkyUI] No Papyrus sources found -- skipping.")
    add_custom_target("Papyrus")
    set(Papyrus_OUTPUT "")
endif()

# ==============================================================================
# § 5  ActionScript / SWF Compilation
# ==============================================================================
#
# Architecture: hybrid global-assemble / per-SWF-inject
#
#   Phase 1 (configure): Init global state
#   Phase 2 (configure): Per-SWF loop — register sources, create inject commands
#   Phase 3 (configure): Finalize — create single global assemble target
#
# Build-time dependency graph:
#
#   ActionScript_Assemble (1 cmake -P, all sources)
#     ↓ add_dependencies (ORDER-ONLY: ordering guarantee, not file dependency)
#   AS_bartermenu     ← DEPENDS: bartermenu_sources + bartermenu.swf
#   AS_containermenu  ← DEPENDS: containermenu_sources + containermenu.swf
#   ...               ← all inject steps run in PARALLEL under Ninja
#
# Incremental guarantee:
#   Changing Quest_Journal.as → assemble reruns (cheap, 1 cmake -P) +
#   only quest_journal inject reruns. All other SWFs are untouched.

set(AS_SWF_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/source/actionscript/swf")
set(AS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source/actionscript")

file(GLOB_RECURSE _ALL_SWF_RELPATHS
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/data/interface"
    "${CMAKE_CURRENT_SOURCE_DIR}/data/interface/*.swf"
)

# Phase 1: initialise global ActionScript state
SkyUI_AS_GlobalAssemble_Init(
    AS_SOURCE_DIR   "${AS_SOURCE_DIR}"
    ASSEMBLE_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/AssembleScripts.cmake"
)

set(AS_TARGETS            "")
set(SWF_COMPILED_OUTPUTS  "")
set(SWF_PASSTHROUGH_FILES "")

# Phase 2: per-SWF loop
foreach(SWF_REL ${_ALL_SWF_RELPATHS})
    get_filename_component(SWF_NAME_WE  "${SWF_REL}" NAME_WE)
    get_filename_component(SWF_DIR_PART "${SWF_REL}" DIRECTORY)

    if(SWF_DIR_PART)
        set(_CMAKE_REL  "${SWF_DIR_PART}/${SWF_NAME_WE}.cmake")
        string(REPLACE "/" "_" _VAR_PREFIX "${SWF_DIR_PART}/${SWF_NAME_WE}")
    else()
        set(_CMAKE_REL  "${SWF_NAME_WE}.cmake")
        set(_VAR_PREFIX "${SWF_NAME_WE}")
    endif()

    set(_SWF_CMAKE_FILE "${AS_SWF_DIR}/${_CMAKE_REL}")

    if(FFDEC_CLI AND EXISTS "${_SWF_CMAKE_FILE}")
        include("${_SWF_CMAKE_FILE}")

        set(_AS_TARGET "AS_${_VAR_PREFIX}")

        set(_FRAME_SOURCES_ARG "")
        if(DEFINED ${_VAR_PREFIX}_FRAME_SOURCES AND ${_VAR_PREFIX}_FRAME_SOURCES)
            set(_FRAME_SOURCES_ARG FRAME_SOURCES ${${_VAR_PREFIX}_FRAME_SOURCES})
        endif()

        SkyUI_AS_Add(
            TARGET_NAME "${_AS_TARGET}"
            SWF_REL     "${SWF_REL}"
            SOURCES     ${${_VAR_PREFIX}_SOURCES}
            ${_FRAME_SOURCES_ARG}
        )

        list(APPEND AS_TARGETS           "${_AS_TARGET}")
        list(APPEND SWF_COMPILED_OUTPUTS "${${_AS_TARGET}_OUTPUT}")
    else()
        list(APPEND SWF_PASSTHROUGH_FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/data/interface/${SWF_REL}")
    endif()
endforeach()

# Phase 3: create the single global assemble target
SkyUI_AS_GlobalAssemble_Finalize()

# Aggregate target: builds every SWF
add_custom_target("ActionScript" DEPENDS ${AS_TARGETS})

# ==============================================================================
# § 6  Debug Mode -- Direct Deployment
# ==============================================================================

if(IS_DEBUG_BUILD)

    set(_DEBUG_DEPLOYED "")

    foreach(_PEX ${Papyrus_OUTPUT})
        get_filename_component(_PEX_NAME "${_PEX}" NAME)
        set(_PEX_DEST "${MOD_DEBUG_OUTPUT_DIR}/Scripts/${_PEX_NAME}")

        add_custom_command(
            OUTPUT "${_PEX_DEST}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory
                "${MOD_DEBUG_OUTPUT_DIR}/Scripts"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                "${_PEX}" "${_PEX_DEST}"
            DEPENDS "${_PEX}"
            COMMENT "Deploying ${_PEX_NAME}"
            VERBATIM
        )
        list(APPEND _DEBUG_DEPLOYED "${_PEX_DEST}")
    endforeach()

    foreach(_SWF_OUT ${SWF_COMPILED_OUTPUTS})
        file(RELATIVE_PATH _SWF_REL "${CMAKE_BINARY_DIR}/interface" "${_SWF_OUT}")
        set(_SWF_DEST "${MOD_DEBUG_OUTPUT_DIR}/interface/${_SWF_REL}")
        get_filename_component(_SWF_DEST_DIR "${_SWF_DEST}" DIRECTORY)

        add_custom_command(
            OUTPUT "${_SWF_DEST}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${_SWF_DEST_DIR}"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                "${_SWF_OUT}" "${_SWF_DEST}"
            DEPENDS "${_SWF_OUT}"
            COMMENT "Deploying interface/${_SWF_REL}"
            VERBATIM
        )
        list(APPEND _DEBUG_DEPLOYED "${_SWF_DEST}")
    endforeach()

    foreach(_SWF_SRC ${SWF_PASSTHROUGH_FILES})
        file(RELATIVE_PATH _SWF_REL
            "${CMAKE_CURRENT_SOURCE_DIR}/data/interface" "${_SWF_SRC}")
        set(_SWF_DEST "${MOD_DEBUG_OUTPUT_DIR}/interface/${_SWF_REL}")
        get_filename_component(_SWF_DEST_DIR "${_SWF_DEST}" DIRECTORY)

        add_custom_command(
            OUTPUT "${_SWF_DEST}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${_SWF_DEST_DIR}"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                "${_SWF_SRC}" "${_SWF_DEST}"
            DEPENDS "${_SWF_SRC}"
            COMMENT "Deploying (pass-through) interface/${_SWF_REL}"
            VERBATIM
        )
        list(APPEND _DEBUG_DEPLOYED "${_SWF_DEST}")
    endforeach()

    add_custom_target("deploy_debug" ALL
        DEPENDS ${_DEBUG_DEPLOYED}
        COMMENT "Debug deployment complete -> ${MOD_DEBUG_OUTPUT_DIR}"
    )
    add_dependencies("deploy_debug" "Papyrus" "ActionScript")

# ==============================================================================
# § 7  Release Mode -- BSA + ZIP
# ==============================================================================

else()

    file(GLOB_RECURSE _EXTRA_INTERFACE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/data/interface/*"
    )
    list(FILTER _EXTRA_INTERFACE_FILES EXCLUDE REGEX "\\.swf$")

    BSArchive_Add(
        "BSA"
        OUTPUT  "${CMAKE_BINARY_DIR}/SkyUI_SE.bsa"
        FORMAT  SSE
        FILES
            ${Papyrus_OUTPUT}
            ${SWF_COMPILED_OUTPUTS}
            ${SWF_PASSTHROUGH_FILES}
            ${_EXTRA_INTERFACE_FILES}
        PREFIX
            "${CMAKE_BINARY_DIR}"
            "${CMAKE_CURRENT_SOURCE_DIR}/data"
    )
    add_dependencies("BSA" "Papyrus" "ActionScript")

    set(_BSA_FILE    "${CMAKE_BINARY_DIR}/SkyUI_SE.bsa")
    set(_ESP_FILE    "${CMAKE_CURRENT_SOURCE_DIR}/data/SkyUI_SE.esp")
    set(_ZIP_OUTPUT  "${CMAKE_BINARY_DIR}/SkyUI_SE-${PROJECT_VERSION}.zip")
    set(_STAGING_DIR "${CMAKE_BINARY_DIR}/_Release")
    set(_PACKAGE_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Package.cmake")

    add_custom_command(
        OUTPUT "${_ZIP_OUTPUT}"
        COMMAND "${CMAKE_COMMAND}"
            "-DSTAGING_DIR=${_STAGING_DIR}"
            "-DBSA_FILE=${_BSA_FILE}"
            "-DESP_FILE=${_ESP_FILE}"
            "-DZIP_OUTPUT=${_ZIP_OUTPUT}"
            -P "${_PACKAGE_SCRIPT}"
        DEPENDS
            "${_BSA_FILE}"
            "${_ESP_FILE}"
        COMMENT "Packaging SkyUI_SE-${PROJECT_VERSION}.zip"
        VERBATIM
    )

    add_custom_target("release" ALL
        DEPENDS "${_ZIP_OUTPUT}"
    )
    add_dependencies("release" "BSA")

endif()