#!/usr/bin/env python3
"""
PatchCreationClub.py - Merge Creation Club (Installed Content) visual sprites
from a reference SWF into SkyUI's quest_journal.swf.

Usage:
  python PatchCreationClub.py <input_swf> <before_swf> <output_swf> <ffdec_cli>

The <before_swf> is the vanilla Bethesda quest_journal.swf that contains
the Creation Club panels (CreationListPanel, CreationTextPanel).
"""

import sys
import os
import subprocess
import copy
import xml.etree.ElementTree as ET
import tempfile


def run_ffdec(ffdec, args):
    result = subprocess.run([ffdec] + args, capture_output=True, text=True)
    if result.returncode != 0:
        print("FFDec error:", result.stderr, file=sys.stderr)
        sys.exit(1)


def remap_id_attrib(elem, attr, remap):
    """Remap a single integer attribute using the given mapping dict."""
    val = elem.get(attr)
    if val is not None:
        try:
            iv = int(val)
            if iv in remap:
                elem.set(attr, str(remap[iv]))
        except ValueError:
            pass


def remap_element(elem, id_remap, font_remap):
    """Recursively remap character ID and font ID references in an element."""
    # Definition attributes (the ID of the character being defined)
    for attr in ('shapeId', 'spriteId', 'characterID'):
        remap_id_attrib(elem, attr, id_remap)
    # Reference attributes (references to other characters, e.g. PlaceObject2)
    for attr in ('characterId',):
        remap_id_attrib(elem, attr, id_remap)
    # Font reference attributes
    for attr in ('fontId',):
        remap_id_attrib(elem, attr, font_remap)
    for child in elem:
        remap_element(child, id_remap, font_remap)


def make_place_object2(char_id, depth, name, tx, ty):
    """Create a PlaceObject2Tag XML element."""
    el = ET.Element('item')
    el.set('type', 'PlaceObject2Tag')
    el.set('characterId', str(char_id))
    el.set('clipDepth', '0')
    el.set('depth', str(depth))
    el.set('forceWriteAsLong', 'true')
    el.set('name', name)
    el.set('placeFlagHasCharacter', 'true')
    el.set('placeFlagHasClipActions', 'false')
    el.set('placeFlagHasClipDepth', 'false')
    el.set('placeFlagHasColorTransform', 'false')
    el.set('placeFlagHasMatrix', 'true')
    el.set('placeFlagHasName', 'true')
    el.set('placeFlagHasRatio', 'false')
    el.set('placeFlagMove', 'false')
    el.set('ratio', '0')
    matrix = ET.SubElement(el, 'matrix')
    matrix.set('type', 'MATRIX')
    matrix.set('hasRotate', 'false')
    matrix.set('hasScale', 'false')
    matrix.set('nRotateBits', '0')
    matrix.set('nScaleBits', '0')
    matrix.set('nTranslateBits', '14')
    matrix.set('rotateSkew0', '0.0')
    matrix.set('rotateSkew1', '0.0')
    matrix.set('scaleX', '0.0')
    matrix.set('scaleY', '0.0')
    matrix.set('translateX', str(tx))
    matrix.set('translateY', str(ty))
    return el


def make_export_assets(char_id, name):
    """Create a single-item ExportAssetsTag XML element."""
    el = ET.Element('item')
    el.set('type', 'ExportAssetsTag')
    el.set('forceWriteAsLong', 'true')
    tags_el = ET.SubElement(el, 'tags')
    tag_item = ET.SubElement(tags_el, 'item')
    tag_item.text = str(char_id)
    names_el = ET.SubElement(el, 'names')
    name_item = ET.SubElement(names_el, 'item')
    name_item.text = name
    return el


def main():
    if len(sys.argv) < 5:
        print(f"Usage: {sys.argv[0]} <input_swf> <before_swf> <output_swf> <ffdec_cli>",
              file=sys.stderr)
        sys.exit(1)

    input_swf = sys.argv[1]
    before_swf = sys.argv[2]
    output_swf = sys.argv[3]
    ffdec = sys.argv[4]

    tmpdir = tempfile.mkdtemp(prefix='patch_cc_')
    input_xml = os.path.join(tmpdir, "input.xml")
    before_xml = os.path.join(tmpdir, "before.xml")
    output_xml = os.path.join(tmpdir, "output.xml")

    print("Converting SWFs to XML...")
    run_ffdec(ffdec, ["-swf2xml", input_swf, input_xml])
    run_ffdec(ffdec, ["-swf2xml", before_swf, before_xml])

    input_tree = ET.parse(input_xml)
    before_tree = ET.parse(before_xml)

    input_root = input_tree.getroot()
    before_root = before_tree.getroot()

    input_tags = input_root.find('tags')
    before_tags = before_root.find('tags')

    # ID remapping: before_id -> new_id
    # New characters are assigned IDs starting at 348 (after SkyUI's max of 347)
    id_remap = {
        # New characters (copied from before SWF, assigned new IDs)
        137: 348,  # DefineShape4Tag  (background rect shape)
        138: 349,  # DefineSpriteTag  (background rect sprite wrapper)
        510: 350,  # DefineEditTextTag (cScrollableText text field)
        511: 351,  # DefineSpriteTag  (cScrollableText) -> exported as "cScrollableText"
        512: 352,  # DefineEditTextTag (CREATIONS TOPIC text)
        513: 353,  # DefineEditTextTag (HELP TOPIC text)
        514: 354,  # DefineSpriteTag  (list entry item)
        515: 355,  # DefineSpriteTag  (CreationList) -> exported as "CreationList"
        591: 356,  # DefineShapeTag   (decorative shape)
        595: 357,  # DefineSpriteTag  (CreationListPanel, 20-frame animated)
        596: 358,  # DefineEditTextTag (TitleText)
        597: 359,  # DefineSpriteTag  (CreationTextPanel content)
        598: 360,  # DefineSpriteTag  (CreationTextPanel wrapper, 20-frame animated)
        668: 361,  # DefineSpriteTag  (ButtonMapping 0-frame class sprite)
        # Characters already in SkyUI (remap references to SkyUI's versions)
        471: 161,  # JournalScrollBar -> SkyUI's ScrollBar
        520: 202,  # ButtonArtHolder  -> SkyUI's ButtonArtHolder
    }

    # Font ID remapping: before font IDs -> SkyUI's _sans font (ID 204)
    # The actual game fonts ($EverywhereFont, etc.) are provided by Skyrim at runtime
    font_remap = {
        509: 204,  # $EverywhereFont
        438: 204,  # $EverywhereMediumFont
    }

    # Character definition tags to copy from the before SWF (original IDs)
    chars_to_copy = {137, 138, 510, 511, 512, 513, 514, 515, 591, 595, 596, 597, 598, 668}
    def_id_attribs = ('shapeId', 'spriteId', 'characterID')

    # DoInitActionTag sprite IDs to copy from the before SWF:
    #   511 -> 351  Object.registerClass("cScrollableText", gfx.controls.TextArea)
    #   515 -> 355  Object.registerClass("CreationList", Shared.BSScrollingList)
    #   668 -> 361  Shared.ButtonMapping class implementation
    # ffdec importScript will update these with our compiled ActionScript source.
    init_actions_to_copy = {511, 515, 668}

    # Collect tags to copy from before.xml
    tags_to_insert = []
    for item in before_tags:
        if item.get('type') == 'DoInitActionTag':
            # Selectively copy DoInitActionTag entries needed for class registration
            sid = item.get('spriteId')
            if sid is not None:
                try:
                    if int(sid) in init_actions_to_copy:
                        new_item = copy.deepcopy(item)
                        remap_element(new_item, id_remap, font_remap)
                        tags_to_insert.append(new_item)
                except ValueError:
                    pass
            continue
        for attr in def_id_attribs:
            val = item.get(attr)
            if val is not None:
                try:
                    if int(val) in chars_to_copy:
                        new_item = copy.deepcopy(item)
                        remap_element(new_item, id_remap, font_remap)
                        tags_to_insert.append(new_item)
                        break
                except ValueError:
                    pass

    print(f"Copying {len(tags_to_insert)} tags from before SWF...")

    # Find insertion point: before the first __Packages ExportAssetsTag
    # (which marks the start of the AS2 class definitions section)
    items = list(input_tags)
    insert_idx = len(items)
    for i, item in enumerate(items):
        if item.get('type') == 'ExportAssetsTag':
            names_el = item.find('names')
            if names_el is not None:
                for name_item in names_el:
                    if name_item.text and name_item.text.startswith('__Packages'):
                        insert_idx = i
                        break
            if insert_idx != len(items):
                break

    # Insert new character tags
    for j, new_item in enumerate(tags_to_insert):
        input_tags.insert(insert_idx + j, new_item)

    # Insert ExportAssetsTag entries:
    #   "cScrollableText" and "CreationList" are sprite-level exports (matched by name at root)
    #   "__Packages.Shared.ButtonMapping" is a class-level export (matched by __Packages path)
    export_offset = insert_idx + len(tags_to_insert)
    input_tags.insert(export_offset,     make_export_assets(351, 'cScrollableText'))
    input_tags.insert(export_offset + 1, make_export_assets(355, 'CreationList'))
    input_tags.insert(export_offset + 2, make_export_assets(361, '__Packages.Shared.ButtonMapping'))

    print("Added ExportAssets for cScrollableText (351), CreationList (355), "
          "and __Packages.Shared.ButtonMapping (361)...")

    # Add PlaceObject2 entries to SystemPage sprite (spriteId=275)
    system_page = None
    for item in input_tags:
        if item.get('type') == 'DefineSpriteTag' and item.get('spriteId') == '275':
            system_page = item
            break

    if system_page is None:
        print("ERROR: Could not find SystemPage sprite (spriteId=275)!", file=sys.stderr)
        sys.exit(1)

    subtags = system_page.find('subTags')
    if subtags is None:
        subtags = ET.SubElement(system_page, 'subTags')

    # Insert before ShowFrameTag (so panels appear on frame 1)
    subtag_list = list(subtags)
    sp_insert = len(subtag_list)
    for i, sub in enumerate(subtag_list):
        if sub.get('type') == 'ShowFrameTag':
            sp_insert = i
            break

    subtags.insert(sp_insert,
        make_place_object2(357, 105, 'CreationListPanel', 5690, 1516))
    subtags.insert(sp_insert + 1,
        make_place_object2(360, 109, 'CreationTextPanel', 5708, 299))

    print("Added CreationListPanel (357, depth=105) and CreationTextPanel (360, depth=109) "
          "to SystemPage (spriteId=275)...")

    # Write output XML
    ET.indent(input_tree, space='  ')
    input_tree.write(output_xml, encoding='UTF-8', xml_declaration=True)

    # Convert XML back to SWF
    print(f"Converting XML to SWF -> {output_swf}...")
    os.makedirs(os.path.dirname(os.path.abspath(output_swf)), exist_ok=True)
    run_ffdec(ffdec, ["-xml2swf", output_xml, output_swf])

    print("Done!")


if __name__ == '__main__':
    main()
