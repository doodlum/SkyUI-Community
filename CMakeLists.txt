cmake_minimum_required(VERSION 4.2)

# Suppress CMP0175: external Papyrus.cmake uses VERBATIM with APPEND in
# add_custom_command, which is not supported. Setting OLD silences the
# warning without modifying the upstream module.
#
# Reference: https://cmake.org/cmake/help/latest/policy/CMP0175.html
cmake_policy(SET CMP0175 OLD)

project(
    SkyUI
    VERSION 6.2
    LANGUAGES NONE
)

# ---------------------------------------------------------------------------
# Options & Core Paths
# ---------------------------------------------------------------------------

option(ENABLE_FPS_PATCH "Enable FPS patching" OFF)

# SkyrimSE_PATH: absolute path to the game directory. 
# Defaults to the standard Steam library location if not provided.
if(NOT DEFINED SkyrimSE_PATH OR SkyrimSE_PATH STREQUAL "")
    set(SkyrimSE_PATH "C:/Program Files (x86)/Steam/steamapps/common/Skyrim Special Edition"
        CACHE PATH "Path to Skyrim Special Edition installation")
endif()

# Build type setup
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose build type: Debug or Release" FORCE)
endif()

string(TOUPPER "${CMAKE_BUILD_TYPE}" _BUILD_TYPE_UPPER)
if(_BUILD_TYPE_UPPER STREQUAL "DEBUG")
    set(IS_DEBUG_BUILD TRUE)
else()
    set(IS_DEBUG_BUILD FALSE)
endif()

# Deployment directory for Debug builds
if(IS_DEBUG_BUILD)
    if(NOT DEFINED MOD_DEBUG_PATH OR MOD_DEBUG_PATH STREQUAL "")
        set(MOD_DEBUG_PATH "${CMAKE_CURRENT_SOURCE_DIR}/dist"
            CACHE STRING "Debug output directory (Skyrim Data or MO2 mod folder)" FORCE)
    endif()
endif()

message(STATUS "[Build] Build type : ${CMAKE_BUILD_TYPE}")

# ---------------------------------------------------------------------------
# Module Paths
# ---------------------------------------------------------------------------

list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/external/BethesdaCMakeModules/Modules"
)

include(Papyrus)
include(BSArchive)
include(ImportToSWF)
include(SWFXMLPatch)

# ---------------------------------------------------------------------------
# FFDec CLI Detection
# ---------------------------------------------------------------------------

find_program(FFDEC_CLI
    NAMES ffdec-cli ffdec-cli.exe
    PATHS "${CMAKE_CURRENT_SOURCE_DIR}/tools/FFDec"
    NO_DEFAULT_PATH
)
if(NOT FFDEC_CLI)
    find_program(FFDEC_CLI NAMES ffdec-cli ffdec-cli.exe)
endif()

if(FFDEC_CLI)
    message(STATUS "[Build] FFDec CLI    : ${FFDEC_CLI}")
else()
    message(WARNING
        "[Build] FFDec CLI not found. ActionScript compilation will be skipped.")
endif()

# ---------------------------------------------------------------------------
# Papyrus Scripts
# ---------------------------------------------------------------------------

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
    message(STATUS "[Build] No Papyrus sources found -- skipping.")
    add_custom_target("Papyrus")
    set(Papyrus_OUTPUT "")
endif()

# ---------------------------------------------------------------------------
# ActionScript / SWF Compilation
# ---------------------------------------------------------------------------

set(AS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source/actionscript")

AS_GlobalAssemble_Init(AS_SOURCE_DIR "${AS_SOURCE_DIR}")

set(AS_TARGETS            "")
set(SWF_COMPILED_OUTPUTS  "")

# Load all SWF target definitions from a single file (calls Add_AS for each)
include("${CMAKE_CURRENT_SOURCE_DIR}/source/swfsources.cmake")

AS_GlobalAssemble_Finalize()

add_custom_target("ActionScript" DEPENDS ${AS_TARGETS})

# ---------------------------------------------------------------------------
# Debug Mode -- Direct Deployment
# ---------------------------------------------------------------------------

if(IS_DEBUG_BUILD)

    set(_DEPLOY_SCRIPT    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Deploy.cmake")
    set(_DEPLOY_STAMP     "${CMAKE_BINARY_DIR}/_deploy.stamp")
    set(_DEPLOY_LISTS_DIR "${CMAKE_BINARY_DIR}/_deploy_lists")

    file(MAKE_DIRECTORY "${_DEPLOY_LISTS_DIR}")

    # The .esp lives at data/SkyUI_SE.esp — same path used in the release block.
    set(_ESP_FILE "${CMAKE_CURRENT_SOURCE_DIR}/data/SkyUI_SE.esp")

    # Write list files at configure-time.
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

# ---------------------------------------------------------------------------
# Release Mode -- BSA + ZIP
# ---------------------------------------------------------------------------

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
