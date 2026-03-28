#[=======================================================================[.rst:
ImportToSWF
-----------

Generic ActionScript injection into SWF files using isolated staging.

Usage
^^^^^

Step 1: Before the SWF loop, call once to initialize state:

  AS_GlobalAssemble_Init(
      AS_SOURCE_DIR <path>
  )

Step 2: Inside the SWF loop, call per SWF to define an injection target:

  Add_AS(
      TARGET_NAME <name>
      SWF_REL     <relative/path.swf>
      SWF_INPUT   <absolute/path/to/base.swf>
      SWF_OUTPUT  <absolute/path/to/output.swf>
      SOURCES     <file> [...]
      [FRAME_SOURCES <file> [...]]
  )

Step 3: After the loop, call once (compatibility stub):

  AS_GlobalAssemble_Finalize()

#]=======================================================================]

# ---------------------------------------------------------------------------
# Module Mode (Included in CMakeLists.txt)
# ---------------------------------------------------------------------------
if(NOT CMAKE_SCRIPT_MODE_FILE)

    # Path to this script for build-time execution via cmake -P
    set(_AS_IMPORT_MODULE_SCRIPT "${CMAKE_CURRENT_LIST_FILE}" CACHE INTERNAL "")

    # Define properties only during configuration
    define_property(GLOBAL PROPERTY _AS_SOURCE_DIR)

    # ---------------------------------------------------------------------------
    # AS_GlobalAssemble_Init
    # ---------------------------------------------------------------------------
    function(AS_GlobalAssemble_Init)
        cmake_parse_arguments(ARG "" "AS_SOURCE_DIR" "" ${ARGN})

        if(NOT ARG_AS_SOURCE_DIR)
            message(FATAL_ERROR "AS_GlobalAssemble_Init: AS_SOURCE_DIR is required.")
        endif()

        set_property(GLOBAL PROPERTY _AS_SOURCE_DIR "${ARG_AS_SOURCE_DIR}")
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

        # Validation
        foreach(_VAR TARGET_NAME SWF_REL SWF_INPUT SWF_OUTPUT)
            if(NOT ARG_${_VAR})
                message(FATAL_ERROR "Add_AS: ${_VAR} is required.")
            endif()
        endforeach()

        if(NOT FFDEC_CLI)
            message(FATAL_ERROR "Add_AS: FFDEC_CLI is not set.")
        endif()

        get_property(_AS_SOURCE_DIR GLOBAL PROPERTY _AS_SOURCE_DIR)

        # Define isolated staging directory and helper list files
        set(_TARGET_STAGING "${CMAKE_CURRENT_BINARY_DIR}/_staging/${ARG_TARGET_NAME}")
        set(_SOURCES_LIST_FILE "${_TARGET_STAGING}_sources.txt")
        set(_FRAME_SOURCES_LIST_FILE "${_TARGET_STAGING}_frame_sources.txt")

        # Resolve absolute paths for all sources
        set(_REAL_SOURCES "")
        foreach(_SRC ${ARG_SOURCES})
            if(NOT IS_ABSOLUTE "${_SRC}")
                set(_SRC "${_AS_SOURCE_DIR}/${_SRC}")
            endif()
            list(APPEND _REAL_SOURCES "${_SRC}")
        endforeach()

        set(_REAL_FRAME_SOURCES "")
        foreach(_SRC ${ARG_FRAME_SOURCES})
            if(NOT IS_ABSOLUTE "${_SRC}")
                set(_SRC "${_AS_SOURCE_DIR}/${_SRC}")
            endif()
            list(APPEND _REAL_FRAME_SOURCES "${_SRC}")
        endforeach()

        # Generate source lists only if they changed (prevents global rebuilds)
        string(REPLACE ";" "\n" _SOURCES_CONTENT "${_REAL_SOURCES}")
        file(GENERATE OUTPUT "${_SOURCES_LIST_FILE}" CONTENT "${_SOURCES_CONTENT}\n")

        string(REPLACE ";" "\n" _FRAME_SOURCES_CONTENT "${_REAL_FRAME_SOURCES}")
        file(GENERATE OUTPUT "${_FRAME_SOURCES_LIST_FILE}" CONTENT "${_FRAME_SOURCES_CONTENT}\n")

        # The actual build command
        add_custom_command(
            OUTPUT "${ARG_SWF_OUTPUT}"
            
            # 1. Prepare Staging: Wipes the folder and copies current files (Silent)
            COMMAND "${CMAKE_COMMAND}"
                "-DSTAGING_DIR=${_TARGET_STAGING}"
                "-DSOURCES_FILE=${_SOURCES_LIST_FILE}"
                "-DFRAME_SOURCES_FILE=${_FRAME_SOURCES_LIST_FILE}"
                "-DAS_SOURCE_DIR=${_AS_SOURCE_DIR}"
                "-DSKYUI_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}"
                "-DSKYUI_VERSION_MINOR=${PROJECT_VERSION_MINOR}"
                "-DSKYUI_RELEASE_IDX=${PROJECT_RELEASE_IDX}"
                "-DSKYUI_VERSION_STRING=${PROJECT_VERSION_STRING}"
                "-DVERSION_METADATA_TARGETS=${VERSION_METADATA_TARGETS}"
                -P "${_AS_IMPORT_MODULE_SCRIPT}"

            # 2. Copy Base SWF
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${ARG_SWF_INPUT}" "${ARG_SWF_OUTPUT}"
            
            # 3. Inject ActionScript via FFDec
            COMMAND "${CMAKE_COMMAND}" -E echo "[Build] ffdec -importScript ${ARG_SWF_REL}"
            COMMAND "${FFDEC_CLI}"
                -config autoDeobfuscate=false,decompile=false
                -onerror abort
                -importScript "${ARG_SWF_OUTPUT}" "${ARG_SWF_OUTPUT}" "${_TARGET_STAGING}"
            
            DEPENDS
                "${ARG_SWF_INPUT}"
                ${_REAL_SOURCES}
                ${_REAL_FRAME_SOURCES}
                "${_SOURCES_LIST_FILE}"
            VERBATIM
        )

        add_custom_target("${ARG_TARGET_NAME}"
            DEPENDS "${ARG_SWF_OUTPUT}"
            SOURCES ${_REAL_SOURCES} ${_REAL_FRAME_SOURCES}
        )

        set("${ARG_TARGET_NAME}_OUTPUT" "${ARG_SWF_OUTPUT}" PARENT_SCOPE)
    endfunction()

    # ---------------------------------------------------------------------------
    # AS_GlobalAssemble_Finalize (Compatibility Stub)
    # ---------------------------------------------------------------------------
    function(AS_GlobalAssemble_Finalize)
        # No longer needed for isolated staging, but kept for API compatibility.
    endfunction()

# ---------------------------------------------------------------------------
# Script Mode (Executed during build via cmake -P)
# ---------------------------------------------------------------------------
else()

    # Clean the isolated directory to remove any files that were commented out/deleted
    file(REMOVE_RECURSE "${STAGING_DIR}")
    file(MAKE_DIRECTORY "${STAGING_DIR}/__Packages")

    # Process regular ActionScript classes
    if(EXISTS "${SOURCES_FILE}")
        file(STRINGS "${SOURCES_FILE}" SOURCES)
        foreach(SRC ${SOURCES})
            if(NOT SRC OR NOT EXISTS "${SRC}")
                continue()
            endif()

            # Calculate classpath (strips the first folder like 'Common/' or 'Vanilla/')
            file(RELATIVE_PATH REL "${AS_SOURCE_DIR}" "${SRC}")
            string(FIND "${REL}" "/" SLASH_POS)
            if(SLASH_POS EQUAL -1)
                continue()
            endif()
            math(EXPR AFTER "${SLASH_POS} + 1")
            string(SUBSTRING "${REL}" ${AFTER} -1 CLASSPATH)

            set(DST "${STAGING_DIR}/__Packages/${CLASSPATH}")
            get_filename_component(DST_DIR "${DST}" DIRECTORY)
            file(MAKE_DIRECTORY "${DST_DIR}")

            list(FIND VERSION_METADATA_TARGETS "${CLASSPATH}" _TARGET_INDEX)

            if(_TARGET_INDEX GREATER -1)
                file(READ "${SRC}" _CONTENT)

                set(_INJECTION "\n    static var SKYUI_RELEASE_IDX = ${SKYUI_RELEASE_IDX};")
                string(APPEND _INJECTION "\n    static var SKYUI_VERSION_MAJOR = ${SKYUI_VERSION_MAJOR};")
                string(APPEND _INJECTION "\n    static var SKYUI_VERSION_MINOR = ${SKYUI_VERSION_MINOR};")
                string(APPEND _INJECTION "\n    static var SKYUI_VERSION_STRING = \"${SKYUI_VERSION_STRING}\";\n")

                if(_CONTENT MATCHES "class[ \t\r\n]+[^\{]+\\{")
                    string(REGEX REPLACE "(class[ \t\r\n]+[^\{]+\\{)" "\\1${_INJECTION}" _MODIFIED_CONTENT "${_CONTENT}")
                    file(WRITE "${DST}" "${_MODIFIED_CONTENT}")
                else()
                    file(COPY_FILE "${SRC}" "${DST}")
                endif()
            else()
                file(COPY_FILE "${SRC}" "${DST}" ONLY_IF_DIFFERENT)
            endif()
        endforeach()
    endif()

    # Process Frame sources (placed in the root of the import directory)
    if(DEFINED FRAME_SOURCES_FILE AND EXISTS "${FRAME_SOURCES_FILE}")
        file(STRINGS "${FRAME_SOURCES_FILE}" FRAME_SOURCES)
        foreach(SRC ${FRAME_SOURCES})
            if(SRC AND EXISTS "${SRC}")
                get_filename_component(FNAME "${SRC}" NAME)
                set(DST "${STAGING_DIR}/${FNAME}")
                
                file(READ "${SRC}" _CONTENT)
                if(DEFINED SKYUI_VERSION_MAJOR)
                    string(REGEX REPLACE "static var SKYUI_VERSION_MAJOR = [0-9]+;" "static var SKYUI_VERSION_MAJOR = ${SKYUI_VERSION_MAJOR};" _CONTENT "${_CONTENT}")
                    string(REGEX REPLACE "static var SKYUI_VERSION_MINOR = [0-9]+;" "static var SKYUI_VERSION_MINOR = ${SKYUI_VERSION_MINOR};" _CONTENT "${_CONTENT}")
                endif()
                file(WRITE "${DST}" "${_CONTENT}")
            endif()
        endforeach()
    endif()
endif()

# ===========================================================================
# REFERENCE: Previous Global Staging Implementation (Sync-based)
# ===========================================================================
# function(AS_GlobalAssemble_Finalize_OLD)
#     get_property(_AS_SOURCE_DIR     GLOBAL PROPERTY _AS_SOURCE_DIR)
#     get_property(_GLOBAL_STAGING    GLOBAL PROPERTY _AS_GLOBAL_STAGING)
#     get_property(_ALL_SOURCES       GLOBAL PROPERTY _AS_ALL_SOURCES)
#     get_property(_ALL_FRAME_SOURCES GLOBAL PROPERTY _AS_ALL_FRAME_SOURCES)
#
#     list(REMOVE_DUPLICATES _ALL_SOURCES)
#     
#     set(_EXPECTED_STAGING_FILES "")
#
#     foreach(SRC IN LISTS _ALL_SOURCES)
#         file(RELATIVE_PATH REL "${_AS_SOURCE_DIR}" "${SRC}")
#         string(FIND "${REL}" "/" SLASH_POS)
#         if(SLASH_POS EQUAL -1)
#             continue()
#         endif()
#         math(EXPR AFTER "${SLASH_POS} + 1")
#         string(SUBSTRING "${REL}" ${AFTER} -1 CLASSPATH)
#         set(DST "${_GLOBAL_STAGING}/__Packages/${CLASSPATH}")
#         list(APPEND _EXPECTED_STAGING_FILES "${DST}")
#         
#         add_custom_command(
#             OUTPUT "${DST}"
#             COMMAND "${CMAKE_COMMAND}" -E make_directory "${DST_DIR}"
#             COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${SRC}" "${DST}"
#             DEPENDS "${SRC}"
#         )
#     endforeach()
#
#     # Cleanup block (Configuration time)
#     if(EXISTS "${_GLOBAL_STAGING}")
#         file(GLOB_RECURSE _ACTUAL_STAGING_FILES "${_GLOBAL_STAGING}/*.as")
#         foreach(_ACTUAL_FILE IN LISTS _ACTUAL_STAGING_FILES)
#             list(FIND _EXPECTED_STAGING_FILES "${_ACTUAL_FILE}" _FOUND_INDEX)
#             if(_FOUND_INDEX EQUAL -1)
#                 message(STATUS "[Cleanup] Removing disabled script: ${_ACTUAL_FILE}")
#                 file(REMOVE "${_ACTUAL_FILE}")
#             endif()
#         endforeach()
#     endif()
# endfunction()