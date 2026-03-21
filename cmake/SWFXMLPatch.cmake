#[=======================================================================[.rst:
SWFXMLPatch
-----------

Logic to rebuild a SWF from its XML source with FPS patching.

Usage
^^^^^

  Add_XML_Base(
      OUTPUT_SWF <absolute/path/to/base.swf>
      XML_PATH   <relative/path/to/patch.xml>
  )

#]=======================================================================]

# ---------------------------------------------------------------------------
# Add_XML_Base
# ---------------------------------------------------------------------------
function(Add_XML_Base)
    cmake_parse_arguments(ARG "" "OUTPUT_SWF;XML_PATH" "" ${ARGN})

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
    set(_XML_PATCHED "${CMAKE_CURRENT_BINARY_DIR}/staging/xml/${ARG_XML_PATH}")
    set(_PATCHER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/tools/xml_fps_patcher.py")

    if(NOT EXISTS "${_XML_SOURCE}")
        message(FATAL_ERROR "Add_XML_Base: XML source not found: ${_XML_SOURCE}")
    endif()

    # List of files to EXCLUDE from FPS patching
    set(_EXCLUSION_LIST
        "skyui/buttonart.xml"
        "skyui/icons_category_celtic.xml"
        "skyui/icons_category_curved.xml"
        "skyui/icons_category_psychosteve.xml"
        "skyui/icons_category_straight.xml"
        "skyui/icons_item_psychosteve.xml"
        "exported/skyui/icons_effect_psychosteve.xml"
        "skyui/mapmarkerart.xml"
    )

    list(FIND _EXCLUSION_LIST "${ARG_XML_PATH}" _EXCLUDED_INDEX)

    if(_EXCLUDED_INDEX EQUAL -1)
        # File is NOT excluded: Patch it
        add_custom_command(
            OUTPUT "${_XML_PATCHED}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "staging/xml"
            COMMAND "${CMAKE_COMMAND}" -E copy "${_XML_SOURCE}" "${_XML_PATCHED}"
            COMMAND "python" "${_PATCHER_SCRIPT}" "--file" "${_XML_PATCHED}" "--fps" "120.0"
            DEPENDS "${_XML_SOURCE}" "${_PATCHER_SCRIPT}"
            COMMENT "[Build] Patching FPS: ${ARG_XML_PATH}"
            VERBATIM
        )
    else()
        # File IS excluded: Just copy it to the staging folder without patching
        add_custom_command(
            OUTPUT "${_XML_PATCHED}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "staging/xml"
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${_XML_SOURCE}" "${_XML_PATCHED}"
            DEPENDS "${_XML_SOURCE}"
            COMMENT "[Build] Skipping FPS patch (excluded): ${ARG_XML_PATH}"
            VERBATIM
        )
    endif()

    # Step 2: Rebuild SWF from (possibly patched) XML
    add_custom_command(
        OUTPUT "${ARG_OUTPUT_SWF}"
        COMMAND "${CMAKE_COMMAND}" -E echo "[Build] ffdec -xml2swf ${ARG_XML_PATH}"
        COMMAND "${FFDEC_CLI}" -xml2swf "${_XML_PATCHED}" "${ARG_OUTPUT_SWF}"
        DEPENDS "${_XML_PATCHED}"
        VERBATIM
    )
endfunction()
