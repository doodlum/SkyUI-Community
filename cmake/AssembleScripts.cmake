# AssembleScripts.cmake - Build-time helper to assemble AS sources for FFDEC
#
# Called at build time via cmake -P with these variables:
#   STAGING_DIR    - Output directory for assembled __Packages tree
#   SOURCES_FILE   - Path to a file listing absolute source paths (one per line)
#   AS_SOURCE_DIR  - Root of source/actionscript (to compute relative paths)
#
# Source layout:  <AS_SOURCE_DIR>/<Module>/<classpath>.as
# Output layout:  <STAGING_DIR>/__Packages/<classpath>.as

file(REMOVE_RECURSE "${STAGING_DIR}")
file(MAKE_DIRECTORY "${STAGING_DIR}/__Packages")

file(STRINGS "${SOURCES_FILE}" SOURCES)

foreach(SRC ${SOURCES})
	# Get path relative to AS_SOURCE_DIR: <Module>/<classpath>.as
	file(RELATIVE_PATH REL "${AS_SOURCE_DIR}" "${SRC}")

	# Strip the first component (module name) to get classpath
	string(FIND "${REL}" "/" SLASH_POS)
	if(SLASH_POS EQUAL -1)
		message(WARNING "Unexpected source path (no module dir): ${SRC}")
		continue()
	endif()
	math(EXPR AFTER "${SLASH_POS} + 1")
	string(SUBSTRING "${REL}" ${AFTER} -1 CLASSPATH)

	set(DST "${STAGING_DIR}/__Packages/${CLASSPATH}")
	if(EXISTS "${SRC}")
		get_filename_component(DST_DIR "${DST}" DIRECTORY)
		file(MAKE_DIRECTORY "${DST_DIR}")
		file(COPY_FILE "${SRC}" "${DST}")
	else()
		message(WARNING "Source not found: ${SRC}")
	endif()
endforeach()
