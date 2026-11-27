#[=======================================================================[.rst:
SWFXMLPatch
-----------

Rebuild a base SWF from its FFDec XML source, and (optionally) apply the FPS
patch to a finished SWF.

Usage
^^^^^

  Add_XML_Base(
      OUTPUT_SWF <absolute/path/to/base.swf>
      XML_PATH   <relative/path/to/source.xml>
      [FPS_STUB  <bool>]   # add the empty FpsScale class the FPS patch needs
  )

  Add_FPS_Patch(
      TARGET_NAME <name>
      SWF_REL     <relative/path.swf>
      SWF_INPUT   <absolute/path/to/unpatched.swf>
      SWF_OUTPUT  <absolute/path/to/patched.swf>
  )

The FPS patch runs on the final, script-injected SWF (so it sees every frame
script and every compiled class): FFDec exports it to XML, tools/xml_fps_patcher.py
raises the frame rate to FPS_PATCH_TARGET and stretches all timelines while
rescaling every frame-number reference (see the script for details; which SWFs
are converted is decided in tools/fps_patch_plan.json), and FFDec rebuilds it.

#]=======================================================================]

# ---------------------------------------------------------------------------
# Add_XML_Base
# ---------------------------------------------------------------------------
function(Add_XML_Base)
    cmake_parse_arguments(ARG "" "OUTPUT_SWF;XML_PATH;FPS_STUB" "" ${ARGN})

    if(NOT ARG_OUTPUT_SWF)
        message(FATAL_ERROR "Add_XML_Base: OUTPUT_SWF is required.")
    endif()
    if(NOT ARG_XML_PATH)
        message(FATAL_ERROR "Add_XML_Base: XML_PATH is required.")
    endif()
    if(NOT FFDEC_CLI)
        message(FATAL_ERROR "Add_XML_Base: FFDEC_CLI is not set.")
    endif()

    set(_XML_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/source/swf/${ARG_XML_PATH}")

    if(NOT EXISTS "${_XML_SOURCE}")
        message(FATAL_ERROR "Add_XML_Base: XML source not found: ${_XML_SOURCE}")
    endif()

    cmake_path(GET ARG_OUTPUT_SWF PARENT_PATH _OUTPUT_SWF_DIR)
    if(ARG_FPS_STUB)
        # Declare an empty skyui.util.FpsScale class so the script import compiles FpsScale.as into it
        # (FFDec only replaces classes that already exist).
        set(_XML_STUBBED "${CMAKE_CURRENT_BINARY_DIR}/staging/xml/${ARG_XML_PATH}")
        cmake_path(GET _XML_STUBBED PARENT_PATH _XML_STUBBED_DIR)
        set(_STUB "${CMAKE_CURRENT_SOURCE_DIR}/tools/fps_helper_stub.py")
        add_custom_command(
            OUTPUT "${ARG_OUTPUT_SWF}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${_OUTPUT_SWF_DIR}" "${_XML_STUBBED_DIR}"
            COMMAND "${Python3_EXECUTABLE}" "${_STUB}" "${_XML_SOURCE}" "${_XML_STUBBED}"
            COMMAND "${CMAKE_COMMAND}" -E echo "[Build] ffdec -xml2swf ${ARG_XML_PATH}"
            COMMAND "${FFDEC_CLI}" -xml2swf "${_XML_STUBBED}" "${ARG_OUTPUT_SWF}"
            DEPENDS "${_XML_SOURCE}" "${_STUB}"
            VERBATIM
        )
    else()
        add_custom_command(
            OUTPUT "${ARG_OUTPUT_SWF}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${_OUTPUT_SWF_DIR}"
            COMMAND "${CMAKE_COMMAND}" -E echo "[Build] ffdec -xml2swf ${ARG_XML_PATH}"
            COMMAND "${FFDEC_CLI}" -xml2swf "${_XML_SOURCE}" "${ARG_OUTPUT_SWF}"
            DEPENDS "${_XML_SOURCE}"
            VERBATIM
        )
    endif()
endfunction()

# ---------------------------------------------------------------------------
# Add_FPS_Patch
# ---------------------------------------------------------------------------
function(Add_FPS_Patch)
    cmake_parse_arguments(ARG "" "TARGET_NAME;SWF_REL;SWF_INPUT;SWF_OUTPUT" "" ${ARGN})

    foreach(_VAR TARGET_NAME SWF_REL SWF_INPUT SWF_OUTPUT)
        if(NOT ARG_${_VAR})
            message(FATAL_ERROR "Add_FPS_Patch: ${_VAR} is required.")
        endif()
    endforeach()
    if(NOT FFDEC_CLI)
        message(FATAL_ERROR "Add_FPS_Patch: FFDEC_CLI is not set.")
    endif()

    string(REGEX REPLACE "\\.swf$" "" _REL_NOEXT "${ARG_SWF_REL}")
    set(_XML_DIR "${CMAKE_CURRENT_BINARY_DIR}/staging/fps")
    set(_XML_IN  "${_XML_DIR}/${_REL_NOEXT}.unpatched.xml")
    set(_XML_OUT "${_XML_DIR}/${_REL_NOEXT}.xml")
    cmake_path(GET _XML_IN PARENT_PATH _XML_SUBDIR)
    cmake_path(GET ARG_SWF_OUTPUT PARENT_PATH _OUTPUT_SWF_DIR)

    set(_TOOLS "${CMAKE_CURRENT_SOURCE_DIR}/tools")
    add_custom_command(
        OUTPUT "${ARG_SWF_OUTPUT}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${_XML_SUBDIR}" "${_OUTPUT_SWF_DIR}"
        COMMAND "${FFDEC_CLI}" -swf2xml "${ARG_SWF_INPUT}" "${_XML_IN}"
        COMMAND "${Python3_EXECUTABLE}" "${_TOOLS}/xml_fps_patcher.py"
                --in "${_XML_IN}" --out "${_XML_OUT}" --swf "${ARG_SWF_REL}"
                --plan "${_TOOLS}/fps_patch_plan.json" --fps "${FPS_PATCH_TARGET}"
                --compat "${FPS_PATCH_COMPAT_ARG}"
        COMMAND "${FFDEC_CLI}" -xml2swf "${_XML_OUT}" "${ARG_SWF_OUTPUT}"
        DEPENDS
            "${ARG_SWF_INPUT}"
            "${_TOOLS}/xml_fps_patcher.py"
            "${_TOOLS}/fps_avm1.py"
            "${_TOOLS}/fps_swfxml.py"
            "${_TOOLS}/fps_patch_plan.json"
        COMMENT "[Build] FPS patch (${FPS_PATCH_TARGET} fps): ${ARG_SWF_REL}"
        JOB_POOL fps_patch
        VERBATIM
    )

    add_custom_target("${ARG_TARGET_NAME}" DEPENDS "${ARG_SWF_OUTPUT}")
endfunction()
