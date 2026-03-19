cmake_minimum_required(VERSION 4.2)

# Suppress CMP0175: external Papyrus.cmake uses VERBATIM with APPEND in
# add_custom_command, which is not supported. Setting OLD silences the
# warning without modifying the upstream module.
# Remove this block once BethesdaCMakeModules is updated.
if(POLICY CMP0175)
    cmake_policy(SET CMP0175 OLD)
endif()

project(
    SkyUI
    VERSION 6.0
    LANGUAGES NONE
)

# ==============================================================================
# § 1  Build Configuration
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
    if(NOT DEFINED MOD_DEBUG_PATH OR MOD_DEBUG_PATH STREQUAL "")
        set(MOD_DEBUG_PATH "${CMAKE_CURRENT_SOURCE_DIR}/dist"
            CACHE STRING "Debug output directory (Skyrim Data or MO2 mod folder)" FORCE)
    endif()

    # Validate at configure time -- before any build targets are created.
    # Normalize path to forward slashes for reliable IS_DIRECTORY check.
    cmake_path(SET _MOD_DEBUG_PATH_NORM NORMALIZE "${MOD_DEBUG_PATH}")
    cmake_path(SET _DEFAULT_PATH_NORM   NORMALIZE "${CMAKE_BINARY_DIR}/data")

    if(_MOD_DEBUG_PATH_NORM STREQUAL _DEFAULT_PATH_NORM)
        # Default output path -- create it automatically, it is not a real mod folder.
        file(MAKE_DIRECTORY "${MOD_DEBUG_PATH}")
    elseif(NOT IS_DIRECTORY "${MOD_DEBUG_PATH}")
        # User-supplied MO2 mod folder -- must already exist.
        # Never auto-create: a typo would silently produce a stray folder.
        message(FATAL_ERROR
            "[SkyUI] Debug output directory does not exist:
"
            "  ${MOD_DEBUG_PATH}
"
            "Create the folder first (e.g. in MO2: right-click -> Create empty mod),
"
            "or leave MOD_DEBUG_PATH empty to use the default: ${CMAKE_BINARY_DIR}/data")
    endif()
    message(STATUS "[SkyUI] Debug output : ${MOD_DEBUG_PATH}")
endif()
# ==============================================================================
# § 2  Module Paths
# ==============================================================================

list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/external/BethesdaCMakeModules/Modules"
)

include(Papyrus)
include(BSArchive)
include(ImportToSWF)

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
#
# CONFIGURE_DEPENDS: CMake re-runs configure automatically when .psc files
# are added or removed.

file(GLOB PAPYRUS_SOURCES
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/source/scripts/*.psc"
)

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

set(AS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source/actionscript")
set(SWF_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source/swf")

SkyUI_AS_GlobalAssemble_Init(
    AS_SOURCE_DIR   "${AS_SOURCE_DIR}"
    ASSEMBLE_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/AssembleScripts.cmake"
)

# Load all SWF source definitions from a single file
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/SWFSources.cmake")

set(AS_TARGETS            "")
set(SWF_COMPILED_OUTPUTS  "")

# Discover all SWFs that have an XML source
file(GLOB_RECURSE _ALL_XML_FILES
    CONFIGURE_DEPENDS
    RELATIVE "${SWF_SOURCE_DIR}"
    "${SWF_SOURCE_DIR}/*.xml"
)

foreach(XML_REL ${_ALL_XML_FILES})
    get_filename_component(SWF_NAME_WE  "${XML_REL}" NAME_WE)
    get_filename_component(SWF_DIR_PART "${XML_REL}" DIRECTORY)

    if(SWF_DIR_PART)
        set(SWF_REL "${SWF_DIR_PART}/${SWF_NAME_WE}.swf")
        string(REPLACE "/" "_" _VAR_PREFIX "${SWF_DIR_PART}/${SWF_NAME_WE}")
    else()
        set(SWF_REL "${SWF_NAME_WE}.swf")
        set(_VAR_PREFIX "${SWF_NAME_WE}")
    endif()

    if(FFDEC_CLI)
        set(_AS_TARGET "AS_${_VAR_PREFIX}")

        set(_SOURCES "")
        if(DEFINED ${_VAR_PREFIX}_SOURCES)
            set(_SOURCES ${${_VAR_PREFIX}_SOURCES})
        endif()

        set(_FRAME_SOURCES_ARG "")
        if(DEFINED ${_VAR_PREFIX}_FRAME_SOURCES)
            set(_FRAME_SOURCES_ARG FRAME_SOURCES ${${_VAR_PREFIX}_FRAME_SOURCES})
        endif()

        SkyUI_AS_Add(
            TARGET_NAME  "${_AS_TARGET}"
            SWF_REL      "${SWF_REL}"
            SOURCES      ${_SOURCES}
            ${_FRAME_SOURCES_ARG}
        )

        list(APPEND AS_TARGETS           "${_AS_TARGET}")
        list(APPEND SWF_COMPILED_OUTPUTS "${${_AS_TARGET}_OUTPUT}")
    else()
        message(WARNING "[SkyUI] FFDec CLI not found, skipping XML build for ${SWF_REL}")
    endif()
endforeach()

SkyUI_AS_GlobalAssemble_Finalize()

add_custom_target("ActionScript" DEPENDS ${AS_TARGETS})

# ==============================================================================
# § 6  Debug Mode -- Direct Deployment
# ==============================================================================
#
# Deploy uses a single cmake -P process (cmake/Deploy.cmake) instead of one
# cmake process per file, eliminating ~38 subprocess launches per build.
#
# File lists are written to disk at configure-time and read by the script at
# build-time. This avoids the semicolon-as-separator ambiguity that occurs
# when passing CMake lists via -D on MSBuild generators.

if(IS_DEBUG_BUILD)

    set(_DEPLOY_SCRIPT    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Deploy.cmake")
    set(_DEPLOY_STAMP     "${CMAKE_BINARY_DIR}/_deploy.stamp")
    set(_DEPLOY_LISTS_DIR "${CMAKE_BINARY_DIR}/_deploy_lists")

    file(MAKE_DIRECTORY "${_DEPLOY_LISTS_DIR}")

    # The .esp lives at data/SkyUI_SE.esp — same path used in the release block.
    set(_ESP_FILE "${CMAKE_CURRENT_SOURCE_DIR}/data/SkyUI_SE.esp")

    # Write list files at configure-time.
    # One absolute path per line — read via file(STRINGS) in Deploy.cmake.
    list(JOIN Papyrus_OUTPUT        "\n" _PEX_CONTENT)
    list(JOIN SWF_COMPILED_OUTPUTS  "\n" _SWF_COMPILED_CONTENT)

    file(WRITE "${_DEPLOY_LISTS_DIR}/pex_files.txt"       "${_PEX_CONTENT}")
    file(WRITE "${_DEPLOY_LISTS_DIR}/swf_compiled.txt"    "${_SWF_COMPILED_CONTENT}")
    file(WRITE "${_DEPLOY_LISTS_DIR}/swf_passthrough.txt" "") # Obsolete
    file(WRITE "${_DEPLOY_LISTS_DIR}/esp_file.txt"        "${_ESP_FILE}")

    add_custom_command(
        OUTPUT "${_DEPLOY_STAMP}"
        COMMAND "${CMAKE_COMMAND}"
            "-DOUTPUT_DIR=${MOD_DEBUG_PATH}"
            "-DDEPLOY_LISTS_DIR=${_DEPLOY_LISTS_DIR}"
            "-DSWF_COMPILED_BASE=${CMAKE_BINARY_DIR}/interface"
            "-DSWF_PASSTHROUGH_BASE=${CMAKE_CURRENT_SOURCE_DIR}/data/interface"
            -P "${_DEPLOY_SCRIPT}"
        COMMAND "${CMAKE_COMMAND}" -E touch "${_DEPLOY_STAMP}"
        DEPENDS
            ${Papyrus_OUTPUT}
            ${SWF_COMPILED_OUTPUTS}
            "${_ESP_FILE}"
        COMMENT "Deploying to ${MOD_DEBUG_PATH}"
        VERBATIM
    )

    add_custom_target("deploy_debug" ALL
        DEPENDS "${_DEPLOY_STAMP}"
    )
    add_dependencies("deploy_debug" "Papyrus" "ActionScript")

# ==============================================================================
# § 7  Release Mode -- BSA + ZIP
# ==============================================================================

else()

    file(GLOB_RECURSE _EXTRA_INTERFACE_FILES
        CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/data/interface/*"
    )
    list(FILTER _EXTRA_INTERFACE_FILES EXCLUDE REGEX "\\.swf$")

    cmake_path(SET _PREFIX_BUILD "${CMAKE_BINARY_DIR}" NORMALIZE)
    cmake_path(SET _PREFIX_DATA  "${CMAKE_CURRENT_SOURCE_DIR}/data" NORMALIZE)

    BSArchive_Add(
        "BSA"
        OUTPUT  "${CMAKE_BINARY_DIR}/SkyUI_SE.bsa"
        FORMAT  SSE
        FILES
            ${Papyrus_OUTPUT}
            ${SWF_COMPILED_OUTPUTS}
            ${_EXTRA_INTERFACE_FILES}
        PREFIX
            "${_PREFIX_BUILD}"
            "${_PREFIX_DATA}"
    )
    add_dependencies("BSA" "Papyrus" "ActionScript")

    set(_BSA_FILE       "${CMAKE_BINARY_DIR}/SkyUI_SE.bsa")
    set(_ESP_FILE       "${CMAKE_CURRENT_SOURCE_DIR}/data/SkyUI_SE.esp")
    set(_ZIP_OUTPUT     "${CMAKE_CURRENT_SOURCE_DIR}/dist/SkyUI_SE-${PROJECT_VERSION}.zip")
    set(_STAGING_DIR    "${CMAKE_BINARY_DIR}/_Release")
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