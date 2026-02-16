#[=======================================================================[.rst:
BSArchive
---------

Create BSA (Bethesda Games Studios Archive) files

Usage:

.. code-block:: cmake

  BSArchive_Add(<target> OUTPUT <file>
                FORMAT <TES3|TES4|FO3|FNV|TES5|SSE|FO4|FO4DDS>
                FILES <file> [...]
                [PREFIX <prefix>]
                [ARCHIVE_FLAGS <value>]
                [FILE_FLAGS <value>]
                [COMPRESS] [SHARE])
#]=======================================================================]

macro(BSArchive_FindBSArch)
	find_program(BSARCH_COMMAND "bsarch" PATHS "tools" NO_CACHE)

	if(NOT BSARCH_COMMAND)
		file(DOWNLOAD
			"https://github.com/TES5Edit/TES5Edit/raw/b3235062f275a7d4a94162af910923ba79f0e77a/Tools/BSArchive/bsarch.exe"
			"${CMAKE_CURRENT_BINARY_DIR}/tools/bsarch.exe"
			EXPECTED_HASH SHA3_224=87e25b2c8b6c90c00d3a2141ec2130a97daa184aff5f2d3d6595c872
			STATUS BSARCH_STATUS
		)

		list(GET BSARCH_STATUS 0 BSARCH_ERROR_CODE)
		if(BSARCH_ERROR_CODE)
			list(GET BSARCH_STATUS 1 BSARCH_ERROR_MESSAGE)
			message(FATAL_ERROR "${BSARCH_ERROR_MESSAGE}")
		endif()

		set(BSARCH_COMMAND "${CMAKE_CURRENT_BINARY_DIR}/tools/bsarch.exe")
	endif()
endmacro()

function(BSArchive_Add BSARCHIVE_TARGET)
	set(options COMPRESS SHARE)
	set(oneValueArgs OUTPUT FORMAT ARCHIVE_FLAGS FILE_FLAGS)
	set(multiValueArgs PREFIX FILES)
	cmake_parse_arguments(BSARCHIVE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	cmake_path(ABSOLUTE_PATH BSARCHIVE_OUTPUT BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
	list(APPEND BSARCHIVE_PREFIX "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
	list(REMOVE_DUPLICATES BSARCHIVE_PREFIX)

	BSArchive_FindBSArch()

	set(BSARCHIVE_TEMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/_BSArchive")

	foreach(INPUT_FILE IN ITEMS ${BSARCHIVE_FILES})
		cmake_path(GET INPUT_FILE RELATIVE_PART ARCHIVE_PATH)

		foreach(PREFIX IN ITEMS ${BSARCHIVE_PREFIX})
			cmake_path(IS_PREFIX PREFIX "${INPUT_FILE}" NORMALIZE IN_PREFIX_PATH)
			if(IN_PREFIX_PATH)
				cmake_path(
					RELATIVE_PATH
					INPUT_FILE
					BASE_DIRECTORY "${PREFIX}"
					OUTPUT_VARIABLE ARCHIVE_PATH
				)
				break()
			endif()
		endforeach()

		cmake_path(APPEND
			BSARCHIVE_TEMP_DIR "${ARCHIVE_PATH}"
			OUTPUT_VARIABLE OUTPUT_FILE
		)

		add_custom_command(
			OUTPUT "${OUTPUT_FILE}"
			COMMAND "${CMAKE_COMMAND}" -E copy_if_different
				"${INPUT_FILE}" "${OUTPUT_FILE}"
			DEPENDS "${INPUT_FILE}"
			VERBATIM
		)

		list(APPEND TEMP_FILES "${OUTPUT_FILE}")
	endforeach()

	add_custom_command(
		OUTPUT "${BSARCHIVE_OUTPUT}"
		COMMAND "${BSARCH_COMMAND}" pack
			"${BSARCHIVE_TEMP_DIR}"
			"${BSARCHIVE_OUTPUT}"
			$<$<STREQUAL:$<UPPER_CASE:${BSARCHIVE_FORMAT}>,TES3>:-tes3>
			$<$<STREQUAL:$<UPPER_CASE:${BSARCHIVE_FORMAT}>,TES4>:-tes4>
			$<$<STREQUAL:$<UPPER_CASE:${BSARCHIVE_FORMAT}>,FO3>:-fo3>
			$<$<STREQUAL:$<UPPER_CASE:${BSARCHIVE_FORMAT}>,FNV>:-fnv>
			$<$<STREQUAL:$<UPPER_CASE:${BSARCHIVE_FORMAT}>,TES5>:-tes5>
			$<$<STREQUAL:$<UPPER_CASE:${BSARCHIVE_FORMAT}>,SSE>:-sse>
			$<$<STREQUAL:$<UPPER_CASE:${BSARCHIVE_FORMAT}>,FO4>:-fo4>
			$<$<STREQUAL:$<UPPER_CASE:${BSARCHIVE_FORMAT}>,FO4DDS>:-fo4dds>
			$<$<BOOL:${BSARCHIVE_ARCHIVE_FLAGS}>:-af:${ARCHIVE_FLAGS}>
			$<$<BOOL:${BSARCHIVE_FILE_FLAGS}>:-ff:${FILE_FLAGS}>
			$<$<BOOL:${BSARCHIVE_COMPRESS}>:-z>
			$<$<BOOL:${BSARCHIVE_SHARE}>:-share>
			-mt
		DEPENDS ${TEMP_FILES}
		VERBATIM
	)

	add_custom_target(
		"${BSARCHIVE_TARGET}" ALL
		DEPENDS "${BSARCHIVE_OUTPUT}"
	)
endfunction()
