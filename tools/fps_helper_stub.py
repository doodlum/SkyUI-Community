"""Add an empty skyui.util.FpsScale class to an FFDec SWF XML (build step of the FPS patch).

FFDec's -importScript only replaces AS2 classes that already exist in a SWF (or that an imported class
depends on). The FPS patch makes every SWF's bytecode call skyui.util.FpsScale, which no source file
references, so with ENABLE_FPS_PATCH the build runs this on every base XML: it declares the class
(an empty sprite exported as "__Packages.skyui.util.FpsScale" plus a DoInitAction) on the main timeline's
first frame, and the script import then compiles source/actionscript/Common/skyui/util/FpsScale.as into it.

Usage: python fps_helper_stub.py <in.xml> <out.xml>
"""

import sys
import xml.etree.ElementTree as ET

EXPORT = "__Packages.skyui.util.FpsScale"


def main(inp, out):
    tree = ET.parse(inp)
    swf = tree.getroot()
    tags = swf.find("tags")
    names = [n.text for el in tags if el.get("type") == "ExportAssetsTag" for n in el.iter("item")]
    if EXPORT not in names:
        used = {int(v) for el in swf.iter() for a, v in el.attrib.items()
                if (a.endswith("Id") or a.endswith("ID")) and v.isdigit()}
        sid = 1
        while sid in used:
            sid += 1
        sid = str(sid)
        sprite = ET.Element("item", {"type": "DefineSpriteTag", "forceWriteAsLong": "true", "frameCount": "0",
                                     "hasEndTag": "true", "spriteId": sid})
        ET.SubElement(sprite, "subTags")
        exp = ET.Element("item", {"type": "ExportAssetsTag", "forceWriteAsLong": "true"})
        ET.SubElement(ET.SubElement(exp, "tags"), "item").text = sid
        ET.SubElement(ET.SubElement(exp, "names"), "item").text = EXPORT
        init = ET.Element("item", {"type": "DoInitActionTag", "actionBytes": "00", "forceWriteAsLong": "true",
                                   "spriteId": sid})
        children = list(tags)
        pos = next((i for i, el in enumerate(children) if el.get("type") == "ShowFrameTag"), len(children))
        for el in (init, exp, sprite):
            tags.insert(pos, el)
    tree.write(out, encoding="UTF-8", xml_declaration=True)
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1], sys.argv[2]))
