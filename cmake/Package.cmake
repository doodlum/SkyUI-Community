# cmake/Package.cmake
# Invoked at build time via cmake -P with these variables:
#   STAGING_DIR   - directory to stage files into before zipping
#   BSA_FILE      - absolute path to the built .bsa
#   ESP_FILE      - absolute path to the .esp
#   ZIP_OUTPUT    - absolute path for the output .zip

foreach(REQUIRED_VAR STAGING_DIR BSA_FILE ESP_FILE ZIP_OUTPUT)
    if(NOT DEFINED ${REQUIRED_VAR} OR "${${REQUIRED_VAR}}" STREQUAL "")
        message(FATAL_ERROR "Package.cmake: ${REQUIRED_VAR} is not set.")
    endif()
endforeach()

# 1. Create staging directory
file(MAKE_DIRECTORY "${STAGING_DIR}")

# 2. Copy both files into the staging directory individually
foreach(SRC IN ITEMS "${BSA_FILE}" "${ESP_FILE}")
    if(NOT EXISTS "${SRC}")
        message(FATAL_ERROR "Package.cmake: source file not found:\n  ${SRC}")
    endif()
    get_filename_component(_NAME "${SRC}" NAME)
    file(COPY_FILE "${SRC}" "${STAGING_DIR}/${_NAME}" ONLY_IF_DIFFERENT)
    message(STATUS "  Staged: ${_NAME}")
endforeach()

# 3. Produce the zip.
#
# We use execute_process with WORKING_DIRECTORY so that cmake -E tar sees only
# bare filenames -- this is what puts .bsa and .esp at the archive root with no
# directory prefix, regardless of where the staging directory actually lives.
get_filename_component(_BSA_NAME "${BSA_FILE}" NAME)
get_filename_component(_ESP_NAME "${ESP_FILE}" NAME)

# CMAKE_EXECUTE_PROCESS_COMMAND_ERROR_IS_FATAL (CMake 4.0):
# Any non-zero exit code from execute_process() becomes a fatal error automatically.
# Eliminates the RESULT_VARIABLE / if(NOT ... EQUAL 0) boilerplate.
set(CMAKE_EXECUTE_PROCESS_COMMAND_ERROR_IS_FATAL ANY)

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E tar cf "${ZIP_OUTPUT}" --format=zip
        "${_BSA_NAME}"
        "${_ESP_NAME}"
    WORKING_DIRECTORY "${STAGING_DIR}"
)

message(STATUS "  Created: ${ZIP_OUTPUT}")