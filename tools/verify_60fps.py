
import subprocess
import os
import re

# Mapping from XML path (relative to source/swf/) to CMake target name
XML_TARGETS = [
    ("bartermenu.xml", "AS_bartermenu"),
    ("bethesdanetlogin.xml", "AS_bethesdanetlogin"),
    ("book.xml", "AS_book"),
    ("bookmenu.xml", "AS_bookmenu"),
    ("console.xml", "AS_console"),
    ("containermenu.xml", "AS_containermenu"),
    ("craftingmenu.xml", "AS_craftingmenu"),
    ("creationclubmenu.xml", "AS_creationclubmenu"),
    ("creditsmenu.xml", "AS_creditsmenu"),
    ("dialoguemenu.xml", "AS_dialoguemenu"),
    ("exported/skyui/widgetloader.xml", "AS_exported_skyui_widgetloader"),
    ("exported/widgets/skyui/activeeffects.xml", "AS_exported_widgets_skyui_activeeffects"),
    ("fadermenu.xml", "AS_fadermenu"),
    ("favoritesmenu.xml", "AS_favoritesmenu"),
    ("giftmenu.xml", "AS_giftmenu"),
    ("hudmenu.xml", "AS_hudmenu"),
    ("inventorymenu.xml", "AS_inventorymenu"),
    ("kinectmenu.xml", "AS_kinectmenu"),
    ("levelupmenu.xml", "AS_levelupmenu"),
    ("loadingmenu.xml", "AS_loadingmenu"),
    ("loadwaitspinner.xml", "AS_loadwaitspinner"),
    ("lockpickingmenu.xml", "AS_lockpickingmenu"),
    ("magicmenu.xml", "AS_magicmenu"),
    ("map.xml", "AS_map"),
    ("messagebox.xml", "AS_messagebox"),
    ("modmanager.xml", "AS_modmanager"),
    ("quest_journal.xml", "AS_quest_journal"),
    ("racesex_menu.xml", "AS_racesex_menu"),
    ("sharedcomponents.xml", "AS_sharedcomponents"),
    ("skyui/bottombar.xml", "AS_skyui_bottombar"),
    ("skyui/buttonart.xml", "AS_skyui_buttonart"),
    ("skyui/configpanel.xml", "AS_skyui_configpanel"),
    ("skyui/icons_category_celtic.xml", "AS_skyui_icons_category_celtic"),
    ("skyui/icons_category_curved.xml", "AS_skyui_icons_category_curved"),
    ("skyui/icons_category_psychosteve.xml", "AS_skyui_icons_category_psychosteve"),
    ("skyui/icons_category_straight.xml", "AS_skyui_icons_category_straight"),
    ("skyui/icons_item_psychosteve.xml", "AS_skyui_icons_item_psychosteve"),
    ("skyui/inventorylists.xml", "AS_skyui_inventorylists"),
    ("skyui/itemcard.xml", "AS_skyui_itemcard"),
    ("skyui/mapmarkerart.xml", "AS_skyui_mapmarkerart"),
    ("skyui/mcm_splash.xml", "AS_skyui_mcm_splash"),
    ("skyui/skyui_splash.xml", "AS_skyui_skyui_splash"),
    ("sleepwaitmenu.xml", "AS_sleepwaitmenu"),
    ("startmenu.xml", "AS_startmenu"),
    ("statsmenu.xml", "AS_statsmenu"),
    ("streaminginstall.xml", "AS_streaminginstall"),
    ("textentry.xml", "AS_textentry"),
    ("titles.xml", "AS_titles"),
    ("trainingmenu.xml", "AS_trainingmenu"),
    ("tutorialmenu.xml", "AS_tutorialmenu"),
    ("tweenmenu.xml", "AS_tweenmenu"),
    ("widgetoverlay.xml", "AS_widgetoverlay"),
]

def run(cmd):
    try:
        process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, stderr = process.communicate()
        return process.returncode, stdout, stderr
    except Exception as e:
        return -1, "", str(e)

def main():
    results = []
    
    if not os.path.exists("build/release"):
        print("Build directory not found. Please configure CMake first.")
        return

    for xml_rel, target in XML_TARGETS:
        xml_path = os.path.normpath(os.path.join("source/swf", xml_rel))
        print(f"--- Verifying {xml_rel} ---")
        
        # 1. Checkout fresh from main
        subprocess.run(f"git checkout origin/main -- {xml_path}", shell=True, capture_output=True)
        
        # 2. Patch
        patch_cmd = f"python tools/xml_60fps_patcher.py --file {xml_path}"
        rc, out, err = run(patch_cmd)
        if rc != 0:
            print(f"  PATCH FAILED: {err}")
            results.append((xml_rel, "PATCH_FAIL", err))
            continue
            
        # 3. Build
        build_cmd = f"cmake --build build/release --target {target} -j 1"
        rc, out, err = run(build_cmd)
        if rc != 0:
            print(f"  BUILD FAILED")
            error_msg = "Unknown error"
            combined = out + err
            severe_match = re.search(r'SEVERE: (.*)', combined, re.DOTALL)
            if severe_match:
                error_msg = severe_match.group(1).split('\n')[0]
            elif "NoSuchFieldException" in combined:
                field_match = re.search(r'java.lang.NoSuchFieldException: (.*)', combined)
                if field_match: error_msg = f"NoSuchFieldException: {field_match.group(1)}"
            elif "NullPointerException" in combined:
                error_msg = "NullPointerException"
            
            results.append((xml_rel, "BUILD_FAIL", error_msg))
        else:
            print(f"  SUCCESS")
            results.append((xml_rel, "SUCCESS", ""))

    print("\n\n=== FINAL RESULTS ===")
    success_count = sum(1 for r in results if r[1] == "SUCCESS")
    print(f"Passed: {success_count}/{len(results)}")
    
    for xml_rel, status, err in results:
        if status != "SUCCESS":
            print(f"[FAILED] {xml_rel}: {err}")

if __name__ == "__main__":
    main()
