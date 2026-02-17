cmake_minimum_required(VERSION 3.24)

project(
	SkyUI
	VERSION 6.0.0
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

# --- Data files for BSA ---

file(GLOB_RECURSE INTERFACE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/data/interface/*")

BSArchive_Add(
	"BSA"
	OUTPUT "SkyUI_SE.bsa"
	FORMAT SSE
	FILES ${Papyrus_OUTPUT} ${INTERFACE_FILES}
	PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/data"
)

add_dependencies("BSA" "Papyrus")

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
