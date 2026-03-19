# cmake/SWFSources.cmake
# Consolidated source and path mapping for all SWF targets.
# Only importing files that are DIFFERENT from what is already in the SWF.
# Relative paths are automatically prefixed with source/actionscript/.

# ---- Shared source groups ----------------------------------------------------

set(CORE_SOURCES
    Common/skyui/defines/Armor.as
    Common/skyui/defines/Form.as
    Common/skyui/defines/Item.as
    Common/skyui/defines/Material.as
    Common/skyui/defines/Weapon.as
    Common/skyui/filter/NameFilter.as
)

set(ITEM_MENU_CORE
    ${CORE_SOURCES}
    ItemMenus/InventoryDataSetter.as
    ItemMenus/InventoryIconSetter.as
    ItemMenus/ItemMenu.as
)

# ---- Helper macro ------------------------------------------------------------

macro(Add_SkyUI_SWF _TARGET_NAME _SWF_REL _XML_PATH)
    SkyUI_AS_Add(
        TARGET_NAME  "AS_${_TARGET_NAME}"
        SWF_REL      "${_SWF_REL}"
        XML_PATH     "${_XML_PATH}"
        SOURCES      ${ARGN}
    )
    list(APPEND AS_TARGETS           "AS_${_TARGET_NAME}")
    list(APPEND SWF_COMPILED_OUTPUTS "${AS_${_TARGET_NAME}_OUTPUT}")
endmacro()

# ---- Target Definitions ------------------------------------------------------

# Item Menus
Add_SkyUI_SWF(bartermenu
    "bartermenu.swf"
    "ItemMenus/bartermenu.xml"
    ${ITEM_MENU_CORE}
)

Add_SkyUI_SWF(containermenu
    "containermenu.swf"
    "ItemMenus/containermenu.xml"
    ${ITEM_MENU_CORE}
)

Add_SkyUI_SWF(inventorymenu
    "inventorymenu.swf"
    "ItemMenus/inventorymenu.xml"
    ${ITEM_MENU_CORE}
)

Add_SkyUI_SWF(magicmenu
    "magicmenu.swf"
    "ItemMenus/magicmenu.xml"
    ${ITEM_MENU_CORE}
    ItemMenus/MagicDataSetter.as
    ItemMenus/MagicIconSetter.as
)

Add_SkyUI_SWF(giftmenu
    "giftmenu.swf"
    "ItemMenus/giftmenu.xml"
    ${ITEM_MENU_CORE}
)

Add_SkyUI_SWF(bottombar
    "skyui/bottombar.swf"
    "ItemMenus/bottombar.xml"
)

Add_SkyUI_SWF(inventorylists
    "skyui/inventorylists.swf"
    "ItemMenus/inventorylists.xml"
    ItemMenus/InventoryLists.as
    ItemMenus/CategoryList.as
)

Add_SkyUI_SWF(itemcard
    "skyui/itemcard.swf"
    "ItemMenus/itemcard.xml"
    ItemMenus/ItemCard.as
)

# Crafting
Add_SkyUI_SWF(craftingmenu
    "craftingmenu.swf"
    "CraftingMenu/craftingmenu.xml"
    ${CORE_SOURCES}
    CraftingMenu/CraftingMenu.as
    CraftingMenu/CraftingDataSetter.as
    CraftingMenu/CraftingIconSetter.as
    CraftingMenu/IconTabList.as
)

# Favorites
Add_SkyUI_SWF(favoritesmenu
    "favoritesmenu.swf"
    "FavoritesMenu/favoritesmenu.xml"
    ${CORE_SOURCES}
    FavoritesMenu/FavoritesMenu.as
    FavoritesMenu/FavoritesIconSetter.as
    FavoritesMenu/FavoritesListEntry.as
    FavoritesMenu/FilterDataExtender.as
    FavoritesMenu/GroupDataExtender.as
)

# Journal & Map
Add_SkyUI_SWF(quest_journal
    "quest_journal.swf"
    "PauseMenu/quest_journal.xml"
    ${CORE_SOURCES}
    PauseMenu/Quest_Journal.as
    PauseMenu/InputMappingArt.as
    PauseMenu/InputMappingList.as
    PauseMenu/ObjectiveScrollingList.as
    PauseMenu/OptionsList.as
    PauseMenu/QuestsPage.as
    PauseMenu/SaveLoadPanel.as
    PauseMenu/SettingsOptionItem.as
    PauseMenu/StatsPage.as
    PauseMenu/SystemPage.as
)

Add_SkyUI_SWF(map
    "map.swf"
    "MapMenu/map.xml"
    ${CORE_SOURCES}
    MapMenu/Map/MapMenu.as
)

# MCM
Add_SkyUI_SWF(modmanager
    "modmanager.swf"
    "ModConfigPanel/modmanager.xml"
    ModConfigPanel/ConfigPanel.as
)

Add_SkyUI_SWF(configpanel     "skyui/configpanel.swf" "ModConfigPanel/configpanel.xml")
Add_SkyUI_SWF(mcm_splash      "skyui/mcm_splash.swf" "ModConfigPanel/mcm_splash.xml")
Add_SkyUI_SWF(skyui_splash    "skyui/skyui_splash.swf" "ModConfigPanel/skyui_splash.xml")

# HUD & Widgets
Add_SkyUI_SWF(activeeffects
    "exported/widgets/skyui/activeeffects.swf"
    "HUDWidgets/activeeffects.xml"
    HUDWidgets/skyui/widgets/activeeffects/ActiveEffectsWidget.as
)

Add_SkyUI_SWF(widgetloader    "exported/skyui/widgetloader.swf" "HUDWidgets/widgetloader.xml")

# Resources
Add_SkyUI_SWF(buttonart       "skyui/buttonart.swf" "Resources/buttonArt.xml")
Add_SkyUI_SWF(mapmarkerart    "skyui/mapmarkerart.swf" "Resources/mapMarkerArt.xml")
Add_SkyUI_SWF(icons_category_celtic      "skyui/icons_category_celtic.swf"      "Resources/icons_category_celtic.xml")
Add_SkyUI_SWF(icons_category_curved      "skyui/icons_category_curved.swf"      "Resources/icons_category_curved.xml")
Add_SkyUI_SWF(icons_category_psychosteve  "skyui/icons_category_psychosteve.swf"  "Resources/icons_category_psychosteve.xml")
Add_SkyUI_SWF(icons_category_straight    "skyui/icons_category_straight.swf"    "Resources/icons_category_straight.xml")
Add_SkyUI_SWF(icons_item_psychosteve      "skyui/icons_item_psychosteve.swf"      "Resources/icons_item_psychosteve.xml")
Add_SkyUI_SWF(icons_effect_psychosteve    "exported/skyui/icons_effect_psychosteve.swf" "Resources/icons_effect_psychosteve.xml")

# Vanilla / Shared
Add_SkyUI_SWF(hudmenu
    "hudmenu.swf"
    "Vanilla/hudmenu.xml"
    Vanilla/HUDMenu.as
)

Add_SkyUI_SWF(statsmenu
    "statsmenu.swf"
    "Vanilla/statsmenu.xml"
    Vanilla/StatsMenu.as
    Vanilla/Shared/BSScrollingList.as
)

Add_SkyUI_SWF(sleepwaitmenu
    "sleepwaitmenu.swf"
    "Vanilla/sleepwaitmenu.xml"
    Vanilla/SleepWaitMenu.as
)

Add_SkyUI_SWF(startmenu       "startmenu.swf"       "Vanilla/startmenu.xml")
Add_SkyUI_SWF(console         "console.swf"         "Vanilla/console.xml")

Add_SkyUI_SWF(bookmenu
    "bookmenu.swf"
    "Vanilla/bookmenu.xml"
    Vanilla/BookBottomBar.as
)

Add_SkyUI_SWF(messagebox
    "messagebox.swf"
    "Vanilla/messagebox.xml"
    Vanilla/MessageBox.as
)

Add_SkyUI_SWF(dialoguemenu
    "dialoguemenu.swf"
    "Vanilla/dialoguemenu.xml"
    Vanilla/DialogueMenu.as
    Vanilla/DialogueCenteredList.as
)

Add_SkyUI_SWF(lockpickingmenu "lockpickingmenu.swf" "Vanilla/lockpickingmenu.xml")
Add_SkyUI_SWF(loadingmenu     "loadingmenu.swf"     "Vanilla/loadingmenu.xml")
Add_SkyUI_SWF(loadwaitspinner "loadwaitspinner.swf" "Vanilla/loadwaitspinner.xml")

Add_SkyUI_SWF(racesex_menu
    "racesex_menu.swf"
    "Vanilla/racesex_menu.xml"
    Vanilla/RaceSexPanels.as
    Vanilla/RaceWidePanel.as
)

Add_SkyUI_SWF(trainingmenu    "trainingmenu.swf"    "Vanilla/trainingmenu.xml")
Add_SkyUI_SWF(tutorialmenu    "tutorialmenu.swf"    "Vanilla/tutorialmenu.xml")
Add_SkyUI_SWF(levelupmenu     "levelupmenu.swf"     "Vanilla/levelupmenu.xml")
Add_SkyUI_SWF(kinectmenu      "kinectmenu.swf"      "Vanilla/kinectmenu.xml")
Add_SkyUI_SWF(fadermenu       "fadermenu.swf"       "Vanilla/fadermenu.xml")
Add_SkyUI_SWF(bethesdanetlogin "bethesdanetlogin.swf" "Vanilla/bethesdanetlogin.xml")
Add_SkyUI_SWF(creationclubmenu "creationclubmenu.swf" "Vanilla/creationclubmenu.xml")
Add_SkyUI_SWF(creditsmenu     "creditsmenu.swf"     "Vanilla/creditsmenu.xml")

Add_SkyUI_SWF(streaminginstall
    "streaminginstall.swf"
    "Vanilla/streaminginstall.xml"
    Vanilla/StreamingInstall.as
)

Add_SkyUI_SWF(book            "book.swf"            "Vanilla/book.xml")
Add_SkyUI_SWF(cursormenu      "cursormenu.swf"      "Vanilla/cursormenu.xml")
Add_SkyUI_SWF(safezone        "safezone.swf"        "Vanilla/safezone.xml")
Add_SkyUI_SWF(sharedcomponents "sharedcomponents.swf" "Vanilla/sharedcomponents.xml")
Add_SkyUI_SWF(textentry       "textentry.swf"       "Vanilla/textentry.xml")
Add_SkyUI_SWF(titles          "titles.swf"          "Vanilla/titles.xml")

Add_SkyUI_SWF(tweenmenu
    "tweenmenu.swf"
    "Vanilla/tweenmenu.xml"
    TweenMenu/TweenMenu.as
)

Add_SkyUI_SWF(widgetoverlay   "widgetoverlay.swf"   "Vanilla/widgetoverlay.xml")
