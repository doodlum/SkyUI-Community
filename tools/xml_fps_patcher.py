
import re
import sys
import math
import os
import argparse
import json

def interp_val(attr_name, v1, v2, t):
    try:
        f1 = float(v1)
        f2 = float(v2)
        res = f1 + (f2 - f1) * t
        
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

def split_tags(body):
    """Stack-based tag splitting to handle nested <item> tags."""
    tags = []
    pos = 0
    while pos < len(body):
        start = body.find('<item', pos)
        if start == -1: break
        
        first_tag_end = body.find('>', start)
        if first_tag_end == -1: break
        
        if body[first_tag_end-1] == '/':
            tags.append(body[start:first_tag_end+1])
            pos = first_tag_end + 1
        else:
            depth = 1
            search_pos = first_tag_end + 1
            while depth > 0:
                next_open = body.find('<item', search_pos)
                next_close = body.find('</item>', search_pos)
                if next_close == -1: break
                if next_open != -1 and next_open < next_close:
                    next_open_end = body.find('>', next_open)
                    if body[next_open_end-1] != '/': depth += 1
                    search_pos = next_open_end + 1
                else:
                    depth -= 1
                    search_pos = next_close + 7
            tags.append(body[start:search_pos])
            pos = search_pos
    return tags

def get_opening_tag_attrs(tag_full):
    match = re.match(r'<item([^>]*)>', tag_full)
    if not match: return {}
    return dict(re.findall(r'(\w+)="([^"]*)"', match.group(1)))

def build_tag_str(t_type, attrs, children_str=""):
    pref_order = ['characterId', 'clipDepth', 'depth', 'forceWriteAsLong', 'name', 'placeFlagHasCharacter', 'placeFlagHasClipActions', 'placeFlagHasClipDepth', 'placeFlagHasColorTransform', 'placeFlagHasMatrix', 'placeFlagHasName', 'placeFlagHasRatio', 'placeFlagMove', 'ratio']
    filtered = {k: v for k, v in attrs.items() if k not in ['type', 'reserved']}
    attr_parts = []
    for k in pref_order:
        if k in filtered: attr_parts.append(f'{k}="{filtered[k]}"')
    for k in sorted(filtered.keys()):
        if k not in pref_order: attr_parts.append(f'{k}="{filtered[k]}"')
    attr_str = " ".join(attr_parts)
    if children_str: return f'        <item type="{t_type}" {attr_str}>\n{children_str}        </item>'
    else: return f'        <item type="{t_type}" {attr_str}/>'

def patch_xml(input_file, output_file, target_fps=120.0, whitelist=None):
    input_file = os.path.normpath(input_file)
    output_file = os.path.normpath(output_file)
    filename = os.path.basename(input_file).lower()
    
    print(f"Patching {input_file} to {target_fps} fps...")
    
    # Get whitelist for this specific file
    file_whitelist = whitelist.get(filename, []) if whitelist else []
    if not file_whitelist:
        print(f"  Info: No whitelist entries for {filename}. Skipping sprites.")

    with open(input_file, 'r', encoding='utf-8') as f: content = f.read()
    fr_match = re.search(r'frameRate="([^"]+)"', content)
    if not fr_match: return
    orig_fps_val = float(fr_match.group(1))
    
    if orig_fps_val >= target_fps:
        if input_file != output_file:
            with open(output_file, 'w', encoding='utf-8', newline='\n') as f: f.write(content)
        return

    multiplier = target_fps / orig_fps_val
    print(f"  Multiplier: {multiplier:.4f} ({orig_fps_val} -> {target_fps})")
    content = re.sub(r'frameRate="[^"]+"', f'frameRate="{target_fps}"', content, count=1)

    def sprite_repl(match):
        header_full, body, footer = match.groups()
        header_attrs = dict(re.findall(r'(\w+)="([^"]*)"', header_full))
        sprite_id = header_attrs.get('spriteId')
        
        # WHITELIST CHECK: Only patch if spriteId is in the list for this file
        if sprite_id not in file_whitelist:
            return match.group(0)
            
        if 'type' in header_attrs: del header_attrs['type']
        old_count = int(header_attrs.get('frameCount', 0))
        if old_count <= 1: return match.group(0)
        
        new_count = int(round(old_count * multiplier))
        header_attrs['frameCount'] = str(new_count)
        attr_str = " ".join(f'{k}="{v}"' for k, v in sorted(header_attrs.items()))
        new_header = f'    <item type="DefineSpriteTag" {attr_str}>\n      <subTags>\n'
        orig_tags = split_tags(body)
        frames = []; curr = []
        for t in orig_tags:
            type_m = re.search(r'type="([^"]+)"', t)
            if not type_m: continue
            t_type = type_m.group(1)
            curr.append((t_type, t))
            if t_type == 'ShowFrameTag': frames.append(curr); curr = []
        if curr: frames.append(curr)
        depth_states = {}; new_frames = [[] for _ in range(new_count)]
        for i, f_tags in enumerate(frames):
            for t_type, t_full in f_tags:
                if t_type.startswith('PlaceObject'):
                    attrs = get_opening_tag_attrs(t_full)
                    d = attrs.get('depth')
                    if d:
                        if d not in depth_states: depth_states[d] = {'history': []}
                        inner_raw = ""
                        inner_m = re.match(r'<item[^>]*>(.*)</item>', t_full, re.DOTALL)
                        if inner_m: inner_raw = inner_m.group(1).strip()
                        m_m = re.search(r'<matrix ([^/>]*/>)', t_full)
                        c_m = re.search(r'<colorTransform ([^/>]*/>)', t_full)
                        depth_states[d]['history'].append({
                            'frame': i, 'type': t_type, 'attrs': attrs, 'full': t_full,
                            'matrix_attrs': dict(re.findall(r'(\w+)="([^"]*)"', m_m.group(1))) if m_m else None,
                            'color_attrs': dict(re.findall(r'(\w+)="([^"]*)"', c_m.group(1))) if c_m else None,
                            'inner_raw': inner_raw
                        })
                elif t_type.startswith('RemoveObject'):
                    attrs = get_opening_tag_attrs(t_full)
                    d = attrs.get('depth')
                    if d:
                        if d not in depth_states: depth_states[d] = {'history': []}
                        depth_states[d]['history'].append({'frame': i, 'remove': True, 'type': t_type, 'full': t_full})
                elif t_type != 'ShowFrameTag':
                    idx = int(round(i * multiplier))
                    if idx < new_count: new_frames[idx].append(t_full)
        for d, data in depth_states.items():
            hist = data['history']
            for k, s1 in enumerate(hist):
                idx1 = int(round(s1['frame'] * multiplier))
                if 'remove' in s1:
                    if idx1 < new_count: new_frames[idx1].append(s1['full'])
                    continue
                s2 = hist[k+1] if k+1 < len(hist) else None
                idx2 = int(round(s2['frame'] * multiplier)) if s2 else new_count
                
                is_animating = False
                if s2 and not 'remove' in s2 and s2['frame'] == s1['frame'] + 1:
                    if s1['matrix_attrs'] != s2['matrix_attrs'] or s1['color_attrs'] != s2['color_attrs']:
                        is_animating = True

                for j in range(idx1, min(idx2, new_count)):
                    if j == idx1:
                        new_frames[j].append(s1['full']); continue
                    if not is_animating: continue
                    t = (j / multiplier - s1['frame'])
                    cur_attrs = s1['attrs'].copy()
                    cur_attrs['placeFlagMove'] = 'true'; cur_attrs['placeFlagHasCharacter'] = 'false'
                    child_lines = []
                    if s1['attrs'].get('placeFlagHasMatrix') == 'true':
                        m2 = s2['matrix_attrs'] if (s2 and not 'remove' in s2 and s2['matrix_attrs']) else s1['matrix_attrs']
                        m_cur = {attr: interp_val(attr, val, m2.get(attr, val), t) for attr, val in s1['matrix_attrs'].items() if attr != 'type'}
                        m_cur['type'] = 'MATRIX'; m_attrs = " ".join(f'{attr}="{m_cur[attr]}"' for attr in sorted(m_cur.keys()))
                        child_lines.append(f'          <matrix {m_attrs}/>')
                    if s1['attrs'].get('placeFlagHasColorTransform') == 'true':
                        c2 = s2['color_attrs'] if (s2 and not 'remove' in s2 and s2['color_attrs']) else s1['color_attrs']
                        c_cur = {attr: interp_val(attr, val, c2.get(attr, val), t) for attr, val in s1['color_attrs'].items() if attr != 'type'}
                        c_cur['type'] = 'CXFORMWITHALPHA'; c_attrs = " ".join(f'{attr}="{c_cur[attr]}"' for attr in sorted(c_cur.keys()))
                        child_lines.append(f'          <colorTransform {c_attrs}/>')
                    if s1['inner_raw']:
                        for line in s1['inner_raw'].split('\n'):
                            l = line.strip()
                            if l and not l.startswith('<matrix') and not l.startswith('<colorTransform'):
                                child_lines.append('          ' + l)
                    new_frames[j].append(build_tag_str(s1['type'], cur_attrs, "\n".join(child_lines) + "\n" if child_lines else ""))
        res_body = ""
        for ftags in new_frames:
            for tag in ftags: res_body += tag.strip() + "\n"
            res_body += '        <item type="ShowFrameTag" forceWriteAsLong="false"/>\n'
        return new_header + res_body + footer

    content = re.sub(r'(<item type="DefineSpriteTag"[^>]*>)\s*<subTags>(.*?)(</subTags>\s*</item>)', sprite_repl, content, flags=re.DOTALL)
    with open(output_file, 'w', encoding='utf-8', newline='\n') as f: f.write(content)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Patch SkyUI XML for higher frame rates')
    parser.add_argument('--file', required=True, help='Path to XML file to patch in-place')
    parser.add_argument('--fps', type=float, default=120.0, help='Target frame rate')
    parser.add_argument('--whitelist', help='Path to whitelist JSON file')
    args = parser.parse_args()
    
    whitelist_data = None
    if args.whitelist and os.path.exists(args.whitelist):
        with open(args.whitelist, 'r') as f:
            whitelist_data = json.load(f)
    elif not args.whitelist:
        # Try to find it in the same dir as the script
        script_dir = os.path.dirname(os.path.abspath(__file__))
        default_wl = os.path.join(script_dir, 'fps_whitelist.json')
        if os.path.exists(default_wl):
            with open(default_wl, 'r') as f:
                whitelist_data = json.load(f)

    if args.file: patch_xml(args.file, args.file, target_fps=args.fps, whitelist=whitelist_data)
