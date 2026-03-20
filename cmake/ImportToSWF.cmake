#[=======================================================================[.rst:
ImportToSWF
-----------

Generic ActionScript injection into SWF files.

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

Step 3: After the loop, call once to perform the global assembly:

  AS_GlobalAssemble_Finalize()

#]=======================================================================]

# ---------------------------------------------------------------------------
# State Management
# ---------------------------------------------------------------------------

# Capture the path to THIS file at include-time so functions called later
# from CMakeLists.txt (like AS_GlobalAssemble_Finalize) know which script 
# to invoke at build-time.
set(_AS_IMPORT_MODULE_SCRIPT "${CMAKE_CURRENT_LIST_FILE}" CACHE INTERNAL "")

define_property(GLOBAL PROPERTY _AS_SOURCE_DIR)
define_property(GLOBAL PROPERTY _AS_GLOBAL_STAGING)
define_property(GLOBAL PROPERTY _AS_ALL_SOURCES)
define_property(GLOBAL PROPERTY _AS_ALL_FRAME_SOURCES)

# ---------------------------------------------------------------------------
# AS_GlobalAssemble_Init
# ---------------------------------------------------------------------------
function(AS_GlobalAssemble_Init)
    cmake_parse_arguments(ARG "" "AS_SOURCE_DIR" "" ${ARGN})

    if(NOT ARG_AS_SOURCE_DIR)
        message(FATAL_ERROR "AS_GlobalAssemble_Init: AS_SOURCE_DIR is required.")
    endif()

    set_property(GLOBAL PROPERTY _AS_SOURCE_DIR      "${ARG_AS_SOURCE_DIR}")
    set_property(GLOBAL PROPERTY _AS_GLOBAL_STAGING  "${CMAKE_BINARY_DIR}/_AS_staging")
    set_property(GLOBAL PROPERTY _AS_ALL_SOURCES "")
    set_property(GLOBAL PROPERTY _AS_ALL_FRAME_SOURCES "")
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

    if(NOT ARG_TARGET_NAME)
        message(FATAL_ERROR "Add_AS: TARGET_NAME is required.")
    endif()
    if(NOT ARG_SWF_REL)
        message(FATAL_ERROR "Add_AS: SWF_REL is required.")
    endif()
    if(NOT ARG_SWF_INPUT)
        message(FATAL_ERROR "Add_AS: SWF_INPUT is required.")
    endif()
    if(NOT ARG_SWF_OUTPUT)
        message(FATAL_ERROR "Add_AS: SWF_OUTPUT is required.")
    endif()
    if(NOT FFDEC_CLI)
        message(FATAL_ERROR "Add_AS: FFDEC_CLI is not set.")
    endif()

    get_property(_AS_SOURCE_DIR   GLOBAL PROPERTY _AS_SOURCE_DIR)
    get_property(_GLOBAL_STAGING  GLOBAL PROPERTY _AS_GLOBAL_STAGING)

    # Prepend source dir to relative paths
    set(_REAL_SOURCES "")
    set(_STAGED_SOURCES "")
    foreach(_SRC ${ARG_SOURCES})
        if(NOT IS_ABSOLUTE "${_SRC}")
            set(_SRC "${_AS_SOURCE_DIR}/${_SRC}")
        endif()
        list(APPEND _REAL_SOURCES "${_SRC}")
        
        file(RELATIVE_PATH REL "${_AS_SOURCE_DIR}" "${_SRC}")
        string(FIND "${REL}" "/" SLASH_POS)
        if(NOT SLASH_POS EQUAL -1)
            math(EXPR AFTER "${SLASH_POS} + 1")
            string(SUBSTRING "${REL}" ${AFTER} -1 CLASSPATH)
            list(APPEND _STAGED_SOURCES "${_GLOBAL_STAGING}/__Packages/${CLASSPATH}")
        endif()
    endforeach()
    set(ARG_SOURCES ${_REAL_SOURCES})

    set(_REAL_FRAME_SOURCES "")
    set(_STAGED_FRAME_SOURCES "")
    foreach(_SRC ${ARG_FRAME_SOURCES})
        if(NOT IS_ABSOLUTE "${_SRC}")
            set(_SRC "${_AS_SOURCE_DIR}/${_SRC}")
        endif()
        list(APPEND _REAL_FRAME_SOURCES "${_SRC}")
        
        get_filename_component(FNAME "${_SRC}" NAME)
        list(APPEND _STAGED_FRAME_SOURCES "${_GLOBAL_STAGING}/${FNAME}")
    endforeach()
    set(ARG_FRAME_SOURCES ${_REAL_FRAME_SOURCES})

    set_property(GLOBAL APPEND PROPERTY _AS_ALL_SOURCES ${ARG_SOURCES})
    if(ARG_FRAME_SOURCES)
        set_property(GLOBAL APPEND PROPERTY _AS_ALL_FRAME_SOURCES ${ARG_FRAME_SOURCES})
    endif()

    add_custom_command(
        OUTPUT "${ARG_SWF_OUTPUT}"
        COMMAND "${CMAKE_COMMAND}" -E echo "[Build] ffdec -importScript ${ARG_SWF_REL}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${ARG_SWF_INPUT}" "${ARG_SWF_OUTPUT}"
        COMMAND "${FFDEC_CLI}"
            -config autoDeobfuscate=false,decompile=false
            -onerror abort
            -importScript "${ARG_SWF_OUTPUT}" "${ARG_SWF_OUTPUT}" "${_GLOBAL_STAGING}"
        DEPENDS
            "${ARG_SWF_INPUT}"
            ${_STAGED_SOURCES}
            ${_STAGED_FRAME_SOURCES}
        VERBATIM
    )

    add_custom_target("${ARG_TARGET_NAME}"
        DEPENDS "${ARG_SWF_OUTPUT}"
        SOURCES ${ARG_SOURCES} ${ARG_FRAME_SOURCES}
    )

    set("${ARG_TARGET_NAME}_OUTPUT" "${ARG_SWF_OUTPUT}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# AS_GlobalAssemble_Finalize
# ---------------------------------------------------------------------------
function(AS_GlobalAssemble_Finalize)
    get_property(_AS_SOURCE_DIR     GLOBAL PROPERTY _AS_SOURCE_DIR)
    get_property(_GLOBAL_STAGING    GLOBAL PROPERTY _AS_GLOBAL_STAGING)
    get_property(_ALL_SOURCES       GLOBAL PROPERTY _AS_ALL_SOURCES)
    get_property(_ALL_FRAME_SOURCES GLOBAL PROPERTY _AS_ALL_FRAME_SOURCES)

    list(REMOVE_DUPLICATES _ALL_SOURCES)
    if(_ALL_FRAME_SOURCES)
        list(REMOVE_DUPLICATES _ALL_FRAME_SOURCES)
    endif()

    foreach(SRC IN LISTS _ALL_SOURCES)
        file(RELATIVE_PATH REL "${_AS_SOURCE_DIR}" "${SRC}")
        string(FIND "${REL}" "/" SLASH_POS)
        if(SLASH_POS EQUAL -1)
            continue()
        endif()
        math(EXPR AFTER "${SLASH_POS} + 1")
        string(SUBSTRING "${REL}" ${AFTER} -1 CLASSPATH)

        set(DST "${_GLOBAL_STAGING}/__Packages/${CLASSPATH}")
        get_filename_component(DST_DIR "${DST}" DIRECTORY)
        
        add_custom_command(
            OUTPUT "${DST}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${DST_DIR}"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${SRC}" "${DST}"
            DEPENDS "${SRC}"
        )
    endforeach()

    foreach(SRC IN LISTS _ALL_FRAME_SOURCES)
        get_filename_component(FNAME "${SRC}" NAME)
        set(DST "${_GLOBAL_STAGING}/${FNAME}")
        
        add_custom_command(
            OUTPUT "${DST}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${_GLOBAL_STAGING}"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${SRC}" "${DST}"
            DEPENDS "${SRC}"
        )
    endforeach()
endfunction()
