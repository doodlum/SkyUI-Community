# cmake/Deploy.cmake
# Invoked at build time via cmake -P with these variables (written as files):
#   OUTPUT_DIR             - destination root (MOD_DEBUG_OUTPUT_DIR)
#   DEPLOY_LISTS_DIR       - directory containing the list files below
#
# List files (written at configure-time, read here):
#   pex_files.txt          - one absolute .pex path per line
#   swf_compiled.txt       - one absolute compiled-SWF path per line
#   swf_passthrough.txt    - one absolute pass-through SWF path per line
#   esp_file.txt           - one absolute .esp path (may be absent in CI)
#
# Context variables passed via -D:
#   SWF_COMPILED_BASE      - build tree interface/ root (for relative-path calc)
#   SWF_PASSTHROUGH_BASE   - source tree data/interface root
#
# Using list files instead of semicolon-joined -D strings avoids the
# MSBuild semicolon-as-separator ambiguity when VERBATIM is used.
# All copies use ONLY_IF_DIFFERENT so unchanged files are not written.

foreach(REQUIRED_VAR OUTPUT_DIR DEPLOY_LISTS_DIR SWF_COMPILED_BASE SWF_PASSTHROUGH_BASE)
    if(NOT DEFINED ${REQUIRED_VAR} OR "${${REQUIRED_VAR}}" STREQUAL "")
        message(FATAL_ERROR "Deploy.cmake: ${REQUIRED_VAR} is not set.")
    endif()
endforeach()

# Helper: deploy a list of files preserving sub-path relative to BASE into SUBDIR
macro(_deploy_files LIST_FILE BASE SUBDIR)
    if(EXISTS "${LIST_FILE}")
        file(STRINGS "${LIST_FILE}" _FILES)
        foreach(_FILE IN LISTS _FILES)
            if(_FILE STREQUAL "")
                continue()
            endif()
            if(NOT EXISTS "${_FILE}")
                message(WARNING "Deploy.cmake: file not found: ${_FILE}")
                continue()
            endif()
            file(RELATIVE_PATH _REL "${BASE}" "${_FILE}")
            set(_DEST "${OUTPUT_DIR}/${SUBDIR}/${_REL}")
            get_filename_component(_DEST_DIR "${_DEST}" DIRECTORY)
            file(MAKE_DIRECTORY "${_DEST_DIR}")
            file(COPY_FILE "${_FILE}" "${_DEST}" ONLY_IF_DIFFERENT)
        endforeach()
    endif()
endmacro()

# ---- Deploy .pex files -------------------------------------------------------
set(_PEX_LIST_FILE "${DEPLOY_LISTS_DIR}/pex_files.txt")
if(EXISTS "${_PEX_LIST_FILE}")
    file(STRINGS "${_PEX_LIST_FILE}" _PEX_FILES)
    set(_SCRIPTS_DIR "${OUTPUT_DIR}/Scripts")
    file(MAKE_DIRECTORY "${_SCRIPTS_DIR}")
    foreach(_PEX IN LISTS _PEX_FILES)
        if(_PEX STREQUAL "")
            continue()
        endif()
        if(NOT EXISTS "${_PEX}")
            message(WARNING "Deploy.cmake: .pex not found: ${_PEX}")
            continue()
        endif()
        get_filename_component(_NAME "${_PEX}" NAME)
        file(COPY_FILE "${_PEX}" "${_SCRIPTS_DIR}/${_NAME}" ONLY_IF_DIFFERENT)
    endforeach()
    message(STATUS "  Deployed Scripts/")
endif()

# ---- Deploy compiled SWFs (from build tree) ----------------------------------
_deploy_files(
    "${DEPLOY_LISTS_DIR}/swf_compiled.txt"
    "${SWF_COMPILED_BASE}"
    "interface"
)
message(STATUS "  Deployed compiled SWFs")

# ---- Deploy pass-through SWFs (from source tree) ----------------------------
_deploy_files(
    "${DEPLOY_LISTS_DIR}/swf_passthrough.txt"
    "${SWF_PASSTHROUGH_BASE}"
    "interface"
)
message(STATUS "  Deployed pass-through SWFs")

# ---- Deploy .esp (debug only) -----------------------------------------------
set(_ESP_LIST_FILE "${DEPLOY_LISTS_DIR}/esp_file.txt")
if(EXISTS "${_ESP_LIST_FILE}")
    file(STRINGS "${_ESP_LIST_FILE}" _ESP_FILES)
    foreach(_ESP IN LISTS _ESP_FILES)
        if(_ESP STREQUAL "")
            continue()
        endif()
        if(NOT EXISTS "${_ESP}")
            message(WARNING "Deploy.cmake: .esp not found: ${_ESP}")
            continue()
        endif()
        # The .esp goes to the mod root (no subdirectory) so MO2 picks it up.
        get_filename_component(_ESP_NAME "${_ESP}" NAME)
        file(COPY_FILE "${_ESP}" "${OUTPUT_DIR}/${_ESP_NAME}" ONLY_IF_DIFFERENT)
    endforeach()
    message(STATUS "  Deployed ${_ESP_NAME}")
endif()

message(STATUS "Deploy complete -> ${OUTPUT_DIR}")