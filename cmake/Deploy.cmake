#[=======================================================================[.rst:
Deploy
------

Build-time helper to deploy built files to the game directory or MO2 folder.
Invoked via cmake -P.

Variables expected:
  OUTPUT_DIR             - destination root (MOD_DEBUG_PATH)
  DEPLOY_LISTS_DIR       - directory containing the list files below
  SWF_COMPILED_BASE      - base dir for relative path calculation (build tree)
  SWF_PASSTHROUGH_BASE   - base dir for relative path calculation (source tree)

List files (in DEPLOY_LISTS_DIR):
  pex_files.txt          - absolute paths to .pex files
  swf_compiled.txt       - absolute paths to built .swf files
  swf_passthrough.txt    - absolute paths to original .swf files
  esp_file.txt           - absolute path to the .esp

#]=======================================================================]

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

foreach(REQUIRED_VAR OUTPUT_DIR DEPLOY_LISTS_DIR SWF_COMPILED_BASE SWF_PASSTHROUGH_BASE)
    if(NOT DEFINED ${REQUIRED_VAR} OR "${${REQUIRED_VAR}}" STREQUAL "")
        message(FATAL_ERROR "Deploy.cmake: ${REQUIRED_VAR} is not set.")
    endif()
endforeach()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function(copy_files_from_list LIST_FILE DEST_ROOT)
    set(BASE_DIR "")
    if(ARGC GREATER 2)
        set(BASE_DIR "${ARGV2}")
    endif()

    if(NOT EXISTS "${LIST_FILE}")
        return()
    endif()

    file(STRINGS "${LIST_FILE}" FILES)

    foreach(SRC ${FILES})
        if(NOT EXISTS "${SRC}")
            message(WARNING "Deploy.cmake: file not found: ${SRC}")
            continue()
        endif()

        if(BASE_DIR)
            file(RELATIVE_PATH REL "${BASE_DIR}" "${SRC}")
            set(DEST "${DEST_ROOT}/${REL}")
        else()
            get_filename_component(NAME "${SRC}" NAME)
            set(DEST "${DEST_ROOT}/${NAME}")
        endif()

        get_filename_component(DEST_DIR "${DEST}" DIRECTORY)
        file(MAKE_DIRECTORY "${DEST_DIR}")

        file(COPY_FILE "${SRC}" "${DEST}" ONLY_IF_DIFFERENT)
    endforeach()
endfunction()

# ---------------------------------------------------------------------------
# Deployment
# ---------------------------------------------------------------------------

# 1. PEX Scripts (flat copy)
copy_files_from_list(
    "${DEPLOY_LISTS_DIR}/pex_files.txt"
    "${OUTPUT_DIR}/scripts"
)
message(STATUS "  Deployed scripts")

# 2. Compiled SWFs (structured copy)
copy_files_from_list(
    "${DEPLOY_LISTS_DIR}/swf_compiled.txt"
    "${OUTPUT_DIR}/interface"
    "${SWF_COMPILED_BASE}"
)
message(STATUS "  Deployed compiled SWFs")

# 3. Passthrough SWFs (structured copy)
copy_files_from_list(
    "${DEPLOY_LISTS_DIR}/swf_passthrough.txt"
    "${OUTPUT_DIR}/interface"
    "${SWF_PASSTHROUGH_BASE}"
)
message(STATUS "  Deployed passthrough SWFs")

# 4. ESP files (flat copy, debug only)
set(_ESP_LIST_FILE "${DEPLOY_LISTS_DIR}/esp_file.txt")
if(EXISTS "${_ESP_LIST_FILE}")
    copy_files_from_list("${_ESP_LIST_FILE}" "${OUTPUT_DIR}")
    message(STATUS "  Deployed ESP")
endif()

message(STATUS "Deploy complete -> ${OUTPUT_DIR}")
