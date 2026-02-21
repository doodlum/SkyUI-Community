"""
MergeSWF.py - Merge shapes, sprites, and frames from a source SWF into a target SWF.

The source SWF's frame 0 (FileAttributes, SetBackgroundColor, DoAction, base
DefineShape2 + PlaceObject2, ShowFrame) is skipped; only icon frames are merged.
Character IDs from the source are offset by the target's max character ID to
avoid collisions.

Usage:
    python cmake/MergeSWF.py <ffdec_cli> <source_swf> <target_swf> [output_swf]

If output_swf is omitted, target_swf is overwritten in place.
"""

import os
import re
import subprocess
import sys
import tempfile


def find_max_char_id(xml_content):
    ids = [int(m) for m in re.findall(r'(?:shapeId|spriteId|characterId)="(\d+)"', xml_content)]
    return max(ids) if ids else 0


def extract_after_first_showframe(xml_content):
    """Return everything from after frame 0's ShowFrameTag up to (not including) </tags>."""
    first_show = xml_content.find('<item type="ShowFrameTag"')
    end_of_show = xml_content.index('/>', first_show) + 2
    close_tags = xml_content.rfind('</tags>')
    return xml_content[end_of_show:close_tags]


def remap_char_ids(content, offset):
    """Offset all shapeId, spriteId, and characterId values by the given amount."""
    def replace(m):
        return '{}="{}"'.format(m.group(1), int(m.group(2)) + offset)
    return re.sub(r'(shapeId|spriteId|characterId)="(\d+)"', replace, content)


def update_top_level_frame_count(xml_content, delta):
    """Increment the frameCount in the top-level <swf> element only."""
    def replace(m):
        return 'frameCount="{}"'.format(int(m.group(1)) + delta)
    # Only replace the first occurrence (the <swf> element's attribute)
    return re.sub(r'frameCount="(\d+)"', replace, xml_content, count=1)


def merge_swfs(ffdec_path, source_swf, target_swf, output_swf):
    src_xml = tempfile.mktemp(suffix='_src.xml')
    tgt_xml = tempfile.mktemp(suffix='_tgt.xml')
    merged_xml = tempfile.mktemp(suffix='_merged.xml')

    try:
        print(f"Converting {os.path.basename(source_swf)} to XML...")
        subprocess.run([ffdec_path, '-swf2xml', source_swf, src_xml], check=True)

        print(f"Converting {os.path.basename(target_swf)} to XML...")
        subprocess.run([ffdec_path, '-swf2xml', target_swf, tgt_xml], check=True)

        with open(src_xml, 'r', encoding='utf-8') as f:
            src_content = f.read()
        with open(tgt_xml, 'r', encoding='utf-8') as f:
            tgt_content = f.read()

        max_id = find_max_char_id(tgt_content)
        print(f"Max character ID in target: {max_id}")

        frames_to_add = src_content.count('<item type="FrameLabelTag"')
        print(f"Frames to merge from source: {frames_to_add}")

        src_frames = extract_after_first_showframe(src_content)
        src_frames = remap_char_ids(src_frames, max_id)

        tgt_merged = update_top_level_frame_count(tgt_content, frames_to_add)

        insert_pos = tgt_merged.rfind('</tags>')
        tgt_merged = tgt_merged[:insert_pos] + src_frames + tgt_merged[insert_pos:]

        with open(merged_xml, 'w', encoding='utf-8') as f:
            f.write(tgt_merged)

        print(f"Converting merged XML to {os.path.basename(output_swf)}...")
        subprocess.run([ffdec_path, '-xml2swf', merged_xml, output_swf], check=True)

        print(f"Done. Merged {frames_to_add} frames into {output_swf}")

    finally:
        for path in (src_xml, tgt_xml, merged_xml):
            if os.path.exists(path):
                os.unlink(path)


if __name__ == '__main__':
    if len(sys.argv) < 4:
        print(__doc__)
        sys.exit(1)

    ffdec  = sys.argv[1]
    source = sys.argv[2]
    target = sys.argv[3]
    output = sys.argv[4] if len(sys.argv) > 4 else target

    merge_swfs(ffdec, source, target, output)
