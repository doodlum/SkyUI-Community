# cmake/AssembleScripts.cmake - Build-time helper to assemble AS sources for FFDec
#
# Called at build time via cmake -P with these variables:
#   STAGING_DIR         - Output directory for assembled __Packages tree
#   SOURCES_FILE        - Path to a file listing absolute source paths (one per line)
#   FRAME_SOURCES_FILE  - (optional) Path to a file listing frame script paths
#   AS_SOURCE_DIR       - Root of source/actionscript (to compute relative paths)
#   PROJECT_VERSION_MAJOR / PROJECT_VERSION_MINOR  - for SkyUISplash patching
#
# Source layout:       <AS_SOURCE_DIR>/<Module>/<classpath>.as
# Output layout:       <STAGING_DIR>/__Packages/<classpath>.as
# Frame script layout: <STAGING_DIR>/<filename>.as  (DoInitAction)
#
# Incremental behaviour:
#   This script is only invoked when at least one .as source has changed
#   (the stamp file in ActionScript.cmake gates it). Within that invocation,
#   file(COPY_FILE ... ONLY_IF_DIFFERENT) skips any files that are already
#   byte-for-byte identical in the staging tree, so only truly changed files
#   are written to disk. The staging tree is NEVER wiped on a clean run --
#   stale files from a removed source are benign (FFDec ignores unknown classes).

file(MAKE_DIRECTORY "${STAGING_DIR}/__Packages")

file(STRINGS "${SOURCES_FILE}" SOURCES)

foreach(SRC ${SOURCES})
    # Compute path relative to AS_SOURCE_DIR: <Module>/<classpath>.as
    file(RELATIVE_PATH REL "${AS_SOURCE_DIR}" "${SRC}")

    # Strip the leading module directory to obtain the AS classpath.
    string(FIND "${REL}" "/" SLASH_POS)
    if(SLASH_POS EQUAL -1)
        message(WARNING "Unexpected source path (no module dir): ${SRC}")
        continue()
    endif()
    math(EXPR AFTER "${SLASH_POS} + 1")
    string(SUBSTRING "${REL}" ${AFTER} -1 CLASSPATH)

    set(DST "${STAGING_DIR}/__Packages/${CLASSPATH}")

    if(NOT EXISTS "${SRC}")
        message(WARNING "Source not found: ${SRC}")
        continue()
    endif()

    get_filename_component(DST_DIR "${DST}" DIRECTORY)
    file(MAKE_DIRECTORY "${DST_DIR}")

    # Only write if content changed -- avoids touching FFDec's input
    # unnecessarily and keeps filesystem timestamps meaningful.
    file(COPY_FILE "${SRC}" "${DST}" ONLY_IF_DIFFERENT)

    # Patch version constants in SkyUISplash.as to match the project version.
    get_filename_component(DST_NAME "${DST}" NAME)
    if(DST_NAME STREQUAL "SkyUISplash.as"
            AND DEFINED PROJECT_VERSION_MAJOR
            AND DEFINED PROJECT_VERSION_MINOR)
        file(READ "${DST}" _SPLASH_CONTENT)
        string(REGEX REPLACE
            "(SKYUI_VERSION_MAJOR[ \t]*=[ \t]*)[0-9]+"
            "\\1${PROJECT_VERSION_MAJOR}"
            _SPLASH_CONTENT "${_SPLASH_CONTENT}")
        string(REGEX REPLACE
            "(SKYUI_VERSION_MINOR[ \t]*=[ \t]*)[0-9]+"
            "\\1${PROJECT_VERSION_MINOR}"
            _SPLASH_CONTENT "${_SPLASH_CONTENT}")
        file(WRITE "${DST}" "${_SPLASH_CONTENT}")
    endif()
endforeach()

# Stage frame scripts at the root of STAGING_DIR.
if(DEFINED FRAME_SOURCES_FILE AND NOT FRAME_SOURCES_FILE STREQUAL "")
    if(EXISTS "${FRAME_SOURCES_FILE}")
        file(STRINGS "${FRAME_SOURCES_FILE}" FRAME_SOURCES)
        foreach(SRC ${FRAME_SOURCES})
            if(EXISTS "${SRC}")
                get_filename_component(FNAME "${SRC}" NAME)
                file(COPY_FILE "${SRC}" "${STAGING_DIR}/${FNAME}" ONLY_IF_DIFFERENT)
            else()
                message(WARNING "Frame source not found: ${SRC}")
            endif()
        endforeach()
    endif()
endif()