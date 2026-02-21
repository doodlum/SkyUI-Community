cmake_minimum_required(VERSION 3.24)

project(
	SkyUI
	VERSION 6.0
	LANGUAGES NONE
)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/BethesdaCMakeModules/Modules")

include(Papyrus)
include(BSArchive)

# --- Papyrus Scripts ---

file(GLOB PAPYRUS_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/source/scripts/*.psc")

Papyrus_Add(
	"Papyrus"
	GAME "${SkyrimSE_PATH}"
	MODE SkyrimSE
	IMPORTS
		"${CMAKE_CURRENT_SOURCE_DIR}/source/scripts"
		"${SkyrimSE_PATH}/Data/Scripts/Source"
	SOURCES ${PAPYRUS_SOURCES}
	OPTIMIZE
	ANONYMIZE
	SKIP_DEFAULT_IMPORTS
)

# --- ActionScript Compilation ---

find_program(FFDEC_CLI NAMES ffdec-cli ffdec-cli.exe
	PATHS "C:/Program Files (x86)/FFDec" "C:/Program Files/FFDec"
)

if(FFDEC_CLI)
	set(AS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source/actionscript")
	set(AS_SWF_DIR "${AS_SOURCE_DIR}/swf")
	set(AS_STAGING_BASE "${CMAKE_CURRENT_BINARY_DIR}/_AS_staging")
	set(ASSEMBLE_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/AssembleScripts.cmake")

	# Collect all SWFs
	file(GLOB_RECURSE SWF_FILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/data/interface"
		"${CMAKE_CURRENT_SOURCE_DIR}/data/interface/*.swf")

	set(AS_TARGETS "")
	foreach(SWF_REL ${SWF_FILES})
		get_filename_component(SWF_NAME_WE "${SWF_REL}" NAME_WE)
		get_filename_component(SWF_DIR "${SWF_REL}" DIRECTORY)

		# Check if a .cmake file exists for this SWF
		if(SWF_DIR)
			set(CMAKE_REL "${SWF_DIR}/${SWF_NAME_WE}.cmake")
		else()
			set(CMAKE_REL "${SWF_NAME_WE}.cmake")
		endif()

		set(SWF_INPUT "${CMAKE_CURRENT_SOURCE_DIR}/data/interface/${SWF_REL}")

		if(EXISTS "${AS_SWF_DIR}/${CMAKE_REL}")
			# Derive variable name: replace / with _ (matches .cmake file convention)
			if(SWF_DIR)
				string(REPLACE "/" "_" VAR_PREFIX "${SWF_DIR}/${SWF_NAME_WE}")
			else()
				set(VAR_PREFIX "${SWF_NAME_WE}")
			endif()
			include("${AS_SWF_DIR}/${CMAKE_REL}")

			set(SOURCES_FILE "${AS_STAGING_BASE}/${VAR_PREFIX}_sources.txt")
			set(AS_STAGING "${AS_STAGING_BASE}/${VAR_PREFIX}")

			# Write source list at configure time
			list(JOIN ${VAR_PREFIX}_SOURCES "\n" SOURCES_CONTENT)
			file(WRITE "${SOURCES_FILE}" "${SOURCES_CONTENT}")

			# Handle optional frame scripts (DoInitAction, staged at root of staging dir)
			set(FRAME_SOURCES_FILE "")
			if(DEFINED ${VAR_PREFIX}_FRAME_SOURCES)
				set(FRAME_SOURCES_FILE "${AS_STAGING_BASE}/${VAR_PREFIX}_frame_sources.txt")
				list(JOIN ${VAR_PREFIX}_FRAME_SOURCES "\n" FRAME_SOURCES_CONTENT)
				file(WRITE "${FRAME_SOURCES_FILE}" "${FRAME_SOURCES_CONTENT}")
			endif()

			add_custom_target("AS_${VAR_PREFIX}"
				COMMAND "${CMAKE_COMMAND}"
					"-DSTAGING_DIR=${AS_STAGING}"
					"-DSOURCES_FILE=${SOURCES_FILE}"
					"-DFRAME_SOURCES_FILE=${FRAME_SOURCES_FILE}"
					"-DAS_SOURCE_DIR=${AS_SOURCE_DIR}"
					"-DPROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}"
					"-DPROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}"
					-P "${ASSEMBLE_SCRIPT}"
				COMMAND "${FFDEC_CLI}" -importScript "${SWF_INPUT}" "${SWF_INPUT}" "${AS_STAGING}"
				COMMENT "Importing ActionScript files into ${SWF_REL}"
			)

			list(APPEND AS_TARGETS "AS_${VAR_PREFIX}")
		endif()
	endforeach()

	add_custom_target("ActionScript" DEPENDS ${AS_TARGETS})

	# --- Data files for BSA ---

	file(GLOB_RECURSE INTERFACE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/data/interface/*")

	BSArchive_Add(
		"BSA"
		OUTPUT "SkyUI_SE.bsa"
		FORMAT SSE
		FILES ${Papyrus_OUTPUT} ${INTERFACE_FILES}
		PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/data"
	)

	add_dependencies("BSA" "Papyrus" "ActionScript")
else()
	message(WARNING "FFDEC CLI not found. SWFs will be packed as-is without ActionScript compilation.")

	# --- Data files for BSA (no FFDEC fallback) ---

	file(GLOB_RECURSE INTERFACE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/data/interface/*")

	BSArchive_Add(
		"BSA"
		OUTPUT "SkyUI_SE.bsa"
		FORMAT SSE
		FILES ${Papyrus_OUTPUT} ${INTERFACE_FILES}
		PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/data"
	)

	add_dependencies("BSA" "Papyrus")
endif()

# --- Release ---

set(RELEASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/release")
set(RELEASE_ZIP "${RELEASE_DIR}/SkyUI_SE-${PROJECT_VERSION}.zip")
set(RELEASE_STAGING "${CMAKE_CURRENT_BINARY_DIR}/_Release")

file(MAKE_DIRECTORY "${RELEASE_STAGING}")

add_custom_command(
	OUTPUT "${RELEASE_ZIP}"
	COMMAND "${CMAKE_COMMAND}" -E make_directory "${RELEASE_DIR}"
	COMMAND "${CMAKE_COMMAND}" -E copy_if_different
		"${CMAKE_CURRENT_BINARY_DIR}/SkyUI_SE.bsa"
		"${CMAKE_CURRENT_SOURCE_DIR}/data/SkyUI_SE.esp"
		"${RELEASE_STAGING}"
	COMMAND "${CMAKE_COMMAND}" -E tar cf "${RELEASE_ZIP}" --format=zip
		"SkyUI_SE.bsa"
		"SkyUI_SE.esp"
	WORKING_DIRECTORY "${RELEASE_STAGING}"
	DEPENDS
		"${CMAKE_CURRENT_BINARY_DIR}/SkyUI_SE.bsa"
		"${CMAKE_CURRENT_SOURCE_DIR}/data/SkyUI_SE.esp"
	VERBATIM
)

add_custom_target(
	"Release" ALL
	DEPENDS "${RELEASE_ZIP}"
)

add_dependencies("Release" "BSA")
