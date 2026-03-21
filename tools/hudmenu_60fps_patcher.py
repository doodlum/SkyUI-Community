
import re
import sys
import math
import os

def interp(attr_name, v1, v2, t):
    try:
        f1 = float(v1)
        f2 = float(v2)
        res = f1 + (f2 - f1) * t
        
        # Attributes that MUST be integers for FFDec xml2swf
        int_attrs = {
            'translateX', 'translateY', 
            'alphaAddTerm', 'redAddTerm', 'greenAddTerm', 'blueAddTerm',
            'alphaMultTerm', 'redMultTerm', 'greenMultTerm', 'blueMultTerm',
            'ratio', 'depth', 'characterId', 'clipDepth', 'nbits',
            'nRotateBits', 'nScaleBits', 'nTranslateBits'
        }
        
        if attr_name in int_attrs:
            return str(int(math.floor(res + 0.5)))
        else:
            return f"{res:.6f}".rstrip('0').rstrip('.')
    except:
        return v1

def interp_attrs(a1, a2, t):
    if not a1 and not a2: return None
    if not a1: return a2
    if not a2: return a1
    res = a1.copy()
    for k in a2:
        if k in a1 and k not in ['type', 'forceWriteAsLong', 'name', 'placeFlagHasCharacter', 'placeFlagHasClipActions', 'placeFlagHasClipDepth', 'placeFlagHasColorTransform', 'placeFlagHasMatrix', 'placeFlagHasName', 'placeFlagHasRatio', 'placeFlagMove', 'hasRotate', 'hasScale', 'hasAddTerms', 'hasMultTerms', 'namedAnchor', 'reserved', 'visible', 'bitmapCache', 'blendMode', 'placeFlagHasBlendMode', 'placeFlagHasCacheAsBitmap', 'placeFlagHasFilterList', 'placeFlagHasVisible', 'placeFlagOpaqueBackground']:
            res[k] = interp(k, a1[k], a2[k], t)
        elif k not in a1:
            res[k] = a2[k]
    return res

RE_ATTR = re.compile(r'(\w+)="([^"]*)"')

def get_clean_attrs(tag_str):
    """Returns a dict of attributes, EXCLUDING 'type'."""
    attrs = dict(RE_ATTR.findall(tag_str))
    if 'type' in attrs:
        del attrs['type']
    return attrs

def build_attr_str(attrs_dict):
    """Builds attribute string from dict, sorted for predictability."""
    return " ".join(f'{k}="{v}"' for k, v in sorted(attrs_dict.items()))

def build_place_tag(tag_type, attrs_dict, children=None):
    allowed = ['characterId', 'depth', 'clipDepth', 'forceWriteAsLong', 'name', 'placeFlagHasCharacter', 'placeFlagHasClipActions', 'placeFlagHasClipDepth', 'placeFlagHasColorTransform', 'placeFlagHasMatrix', 'placeFlagHasName', 'placeFlagHasRatio', 'placeFlagMove', 'ratio', 'reserved', 'visible', 'bitmapCache', 'blendMode', 'placeFlagHasBlendMode', 'placeFlagHasCacheAsBitmap', 'placeFlagHasFilterList', 'placeFlagHasVisible', 'placeFlagOpaqueBackground']
    
    filtered_attrs = {k: v for k, v in attrs_dict.items() if k in allowed}
    
    if tag_type == 'PlaceObject3Tag' and attrs_dict.get('placeFlagHasFilterList') == 'true' and (not children or '<surfaceFilterList' not in children):
        if not children: children = ""
        children += '          <surfaceFilterList/>\n'

    pref_order = ['characterId', 'clipDepth', 'depth', 'forceWriteAsLong', 'name', 'placeFlagHasCharacter', 'placeFlagHasClipActions', 'placeFlagHasClipDepth', 'placeFlagHasColorTransform', 'placeFlagHasMatrix', 'placeFlagHasName', 'placeFlagHasRatio', 'placeFlagMove', 'ratio']
    final_attrs = []
    for k in pref_order:
        if k in filtered_attrs:
            final_attrs.append((k, filtered_attrs[k]))
    for k in sorted(filtered_attrs.keys()):
        if k not in pref_order:
            final_attrs.append((k, filtered_attrs[k]))
    
    attr_str = " ".join(f'{k}="{v}"' for k, v in final_attrs)
    if children:
        return f'        <item type="{tag_type}" {attr_str}>\n{children}        </item>'
    else:
        return f'        <item type="{tag_type}" {attr_str}/>'

def process(input_file, output_file):
    print(f"Processing {input_file}...")
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Update frameRate - surgical replace
    content = content.replace('frameRate="24.0"', 'frameRate="60.0"')

    def sprite_repl(match):
        header_full = match.group(1)
        footer = match.group(3)
        body = match.group(2)
        
        attrs = get_clean_attrs(header_full)
        old_count = int(attrs.get('frameCount', 0))
        if old_count <= 1: return match.group(0)
        
        new_count = int(round(old_count * 2.5))
        attrs['frameCount'] = str(new_count)
        
        # Build header with specific order
        pref_header_order = ['forceWriteAsLong', 'frameCount', 'hasEndTag', 'spriteId']
        final_header_attrs = []
        for k in pref_header_order:
            if k in attrs:
                final_header_attrs.append((k, attrs[k]))
        for k in sorted(attrs.keys()):
            if k not in pref_header_order:
                final_header_attrs.append((k, attrs[k]))
                
        attr_str = " ".join(f'{k}="{v}"' for k, v in final_header_attrs)
        new_header = f'    <item type="DefineSpriteTag" {attr_str}>\n      <subTags>\n'
        
        frames = []
        current_frame = []
        tag_pattern = re.compile(r'<item type="([^"]+)"[^>/]*>.*?</item>|<item type="([^"]+)"[^>]*?/>', re.DOTALL)
        for m in tag_pattern.finditer(body):
            t_full = m.group(0)
            t_type = re.search(r'type="([^"]+)"', t_full).group(1)
            current_frame.append((t_type, t_full))
            if t_type == 'ShowFrameTag':
                frames.append(current_frame)
                current_frame = []
        if current_frame: frames.append(current_frame)
            
        depth_states = {}
        new_frames = [[] for _ in range(new_count)]
        for i in range(len(frames)):
            for t_type, t_full in frames[i]:
                if t_type in ['PlaceObject2Tag', 'PlaceObject3Tag']:
                    t_attrs = get_clean_attrs(t_full)
                    d = t_attrs.get('depth')
                    if d:
                        if d not in depth_states: depth_states[d] = {'history': []}
                        m_match = re.search(r'<matrix ([^/>]*)/?>', t_full)
                        c_match = re.search(r'<colorTransform ([^/>]*)/?>', t_full)
                        f_match = re.search(r'<surfaceFilterList.*?>.*?</surfaceFilterList>', t_full, re.DOTALL) or re.search(r'<surfaceFilterList.*?/>', t_full)
                        depth_states[d]['history'].append({
                            'frame': i, 'type': t_type, 'attrs': t_attrs, 'full': t_full,
                            'matrix': get_clean_attrs(m_match.group(0)) if m_match else None,
                            'color': get_clean_attrs(c_match.group(0)) if c_match else None,
                            'filters': f_match.group(0) if f_match else None
                        })
                elif t_type in ['RemoveObjectTag', 'RemoveObject2Tag']:
                    t_attrs = get_clean_attrs(t_full)
                    d = t_attrs.get('depth')
                    if d:
                        if d not in depth_states: depth_states[d] = {'history': []}
                        depth_states[d]['history'].append({'frame': i, 'remove': True, 'type': t_type, 'full': t_full, 'attrs': t_attrs})
                elif t_type != 'ShowFrameTag':
                    new_idx = int(round(i * 2.5))
                    if new_idx < new_count: new_frames[new_idx].append(t_full)

        for d, data in depth_states.items():
            history = data['history']
            for k in range(len(history)):
                s1 = history[k]
                new_idx1 = int(round(s1['frame'] * 2.5))
                if 'remove' in s1:
                    if new_idx1 < new_count:
                        new_frames[new_idx1].append(s1['full'])
                    continue
                s2 = history[k+1] if k+1 < len(history) else None
                new_idx2 = int(round(s2['frame'] * 2.5)) if s2 else new_count
                for j in range(new_idx1, min(new_idx2, new_count)):
                    t = (j / 2.5 - s1['frame'])
                    if j == new_idx1:
                        new_frames[j].append(s1['full'])
                        continue

                    cur_attrs = s1['attrs'].copy()
                    cur_attrs['placeFlagMove'] = 'true'
                    cur_attrs['placeFlagHasCharacter'] = 'false'
                    
                    children = ""
                    if s1['attrs'].get('placeFlagHasMatrix') == 'true':
                        m2 = s2['matrix'] if s2 and not 'remove' in s2 and s2['frame'] == s1['frame']+1 and s2['attrs'].get('placeFlagHasMatrix') == 'true' else s1['matrix']
                        cur_matrix = interp_attrs(s1['matrix'], m2, t)
                        if cur_matrix: 
                            children += f'          <matrix type="MATRIX" {build_attr_str(cur_matrix)}/>\n'
                    else:
                        cur_attrs['placeFlagHasMatrix'] = 'false'

                    if s1['attrs'].get('placeFlagHasColorTransform') == 'true':
                        c2 = s2['color'] if s2 and not 'remove' in s2 and s2['frame'] == s1['frame']+1 and s2['attrs'].get('placeFlagHasColorTransform') == 'true' else s1['color']
                        cur_color = interp_attrs(s1['color'], c2, t)
                        if cur_color: 
                            children += f'          <colorTransform type="CXFORMWITHALPHA" {build_attr_str(cur_color)}/>\n'
                    else:
                        cur_attrs['placeFlagHasColorTransform'] = 'false'

                    if s1['filters']: children += f'          {s1["filters"].strip()}\n'
                    new_frames[j].append(build_place_tag(s1['type'], cur_attrs, children))

        new_body = ""
        for frame_tags in new_frames:
            for tag in frame_tags: new_body += tag.strip() + "\n"
            new_body += '        <item type="ShowFrameTag" forceWriteAsLong="false"/>\n'
        return new_header + new_body + footer

    print("Running regex substitution...")
    content = re.sub(r'(<item type="DefineSpriteTag"[^>]*>)\s*<subTags>(.*?)(</subTags>\s*</item>)', sprite_repl, content, flags=re.DOTALL)
    print(f"Saving {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f: f.write(content)
    print("Done.")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Patch SkyUI hudmenu.xml for 60fps')
    parser.add_argument('--input', default='source/swf/hudmenu.xml', help='Input XML file')
    parser.add_argument('--output', default='source/swf/hudmenu.xml', help='Output XML file')
    
    args = parser.parse_args()
    
    # Resolve paths relative to project root if script is in tools/
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    input_path = args.input if os.path.isabs(args.input) else os.path.join(project_root, args.input)
    output_path = args.output if os.path.isabs(args.output) else os.path.join(project_root, args.output)
    
    process(input_path, output_path)
