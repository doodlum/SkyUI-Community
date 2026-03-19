# cmake/SWFSources.cmake
# Consolidated source and path mapping for all SWF targets.
# Every relevant ActionScript file is listed here.
# Files that are already identical to what's in the base SWF are commented out.
# Relative paths are automatically prefixed with source/actionscript/.

# ---- Shared source groups ----------------------------------------------------

# (These variables are used for convenience in the lists below)

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

macro(Add_SWF _TARGET_NAME _SWF_REL _XML_PATH)
    SkyUI_AS_Add(
        TARGET_NAME  AS_${_TARGET_NAME}
        SWF_REL      ${_SWF_REL}
        XML_PATH     ${_XML_PATH}
        SOURCES      ${ARGN}
    )
    list(APPEND AS_TARGETS           AS_${_TARGET_NAME})
    list(APPEND SWF_COMPILED_OUTPUTS ${AS_${_TARGET_NAME}_OUTPUT})
endmacro()

# ---- Target Definitions ------------------------------------------------------

# Item Menus
Add_SWF(bartermenu
    bartermenu.swf
    ItemMenus/bartermenu.xml
    # ItemMenus/BarterMenu.as (identical)
    # ItemMenus/BarterDataSetter.as (identical)
    ${ITEM_MENU_CORE}
)

Add_SWF(containermenu
    containermenu.swf
    ItemMenus/containermenu.xml
    # ItemMenus/ContainerMenu.as (identical)
    ${ITEM_MENU_CORE}
)

Add_SWF(inventorymenu
    inventorymenu.swf
    ItemMenus/inventorymenu.xml
    # ItemMenus/InventoryMenu.as (identical)
    ${ITEM_MENU_CORE}
)

Add_SWF(magicmenu
    magicmenu.swf
    ItemMenus/magicmenu.xml
    # ItemMenus/MagicMenu.as (identical)
    ItemMenus/MagicDataSetter.as
    ItemMenus/MagicIconSetter.as
    ${ITEM_MENU_CORE}
)

Add_SWF(giftmenu
    giftmenu.swf
    ItemMenus/giftmenu.xml
    # ItemMenus/GiftMenu.as (identical)
    ${ITEM_MENU_CORE}
)

Add_SWF(bottombar
    skyui/bottombar.swf
    ItemMenus/bottombar.xml
    ItemMenus/BottomBar.as
)

Add_SWF(inventorylists
    skyui/inventorylists.swf
    ItemMenus/inventorylists.xml
    ItemMenus/InventoryLists.as
    ItemMenus/CategoryList.as
)

Add_SWF(itemcard
    skyui/itemcard.swf
    ItemMenus/itemcard.xml
    ItemMenus/ItemCard.as
)

# Crafting
Add_SWF(craftingmenu
    craftingmenu.swf
    CraftingMenu/craftingmenu.xml
    CraftingMenu/CraftingMenu.as
    CraftingMenu/CraftingDataSetter.as
    CraftingMenu/CraftingIconSetter.as
    CraftingMenu/IconTabList.as
    ${CORE_SOURCES}
)

# Favorites
Add_SWF(favoritesmenu
    favoritesmenu.swf
    FavoritesMenu/favoritesmenu.xml
    FavoritesMenu/FavoritesMenu.as
    FavoritesMenu/FavoritesIconSetter.as
    FavoritesMenu/FavoritesListEntry.as
    FavoritesMenu/FilterDataExtender.as
    FavoritesMenu/GroupDataExtender.as
    ${CORE_SOURCES}
)

# Journal & Map
Add_SWF(quest_journal
    quest_journal.swf
    PauseMenu/quest_journal.xml
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
    ${CORE_SOURCES}
)

Add_SWF(map
    map.swf
    MapMenu/map.xml
    MapMenu/Map/MapMenu.as
    ${CORE_SOURCES}
)

# MCM
Add_SWF(modmanager
    modmanager.swf
    ModConfigPanel/modmanager.xml
    ModConfigPanel/ConfigPanel.as
)

Add_SWF(configpanel     skyui/configpanel.swf ModConfigPanel/configpanel.xml)
Add_SWF(mcm_splash      skyui/mcm_splash.swf ModConfigPanel/mcm_splash.xml)
Add_SWF(skyui_splash    skyui/skyui_splash.swf ModConfigPanel/skyui_splash.xml)

# HUD & Widgets
Add_SWF(activeeffects
    exported/widgets/skyui/activeeffects.swf
    HUDWidgets/activeeffects.xml
    HUDWidgets/skyui/widgets/activeeffects/ActiveEffectsWidget.as
)

Add_SWF(widgetloader    exported/skyui/widgetloader.swf HUDWidgets/widgetloader.xml)

# Resources
Add_SWF(buttonart       skyui/buttonart.swf Resources/buttonArt.xml)
Add_SWF(mapmarkerart    skyui/mapmarkerart.swf Resources/mapMarkerArt.xml)
Add_SWF(icons_category_celtic      skyui/icons_category_celtic.swf      Resources/icons_category_celtic.xml)
Add_SWF(icons_category_curved      skyui/icons_category_curved.swf      Resources/icons_category_curved.xml)
Add_SWF(icons_category_psychosteve  skyui/icons_category_psychosteve.swf  Resources/icons_category_psychosteve.xml)
Add_SWF(icons_category_straight    skyui/icons_category_straight.swf    Resources/icons_category_straight.xml)
Add_SWF(icons_item_psychosteve      skyui/icons_item_psychosteve.swf      Resources/icons_item_psychosteve.xml)
Add_SWF(icons_effect_psychosteve    exported/skyui/icons_effect_psychosteve.swf Resources/icons_effect_psychosteve.xml)

# Vanilla / Shared
Add_SWF(hudmenu
    hudmenu.swf
    Vanilla/hudmenu.xml
    Vanilla/HUDMenu.as
)

Add_SWF(statsmenu
    statsmenu.swf
    Vanilla/statsmenu.xml
    Vanilla/StatsMenu.as
    Vanilla/Shared/BSScrollingList.as
)

Add_SWF(sleepwaitmenu
    sleepwaitmenu.swf
    Vanilla/sleepwaitmenu.xml
    Vanilla/SleepWaitMenu.as
)

Add_SWF(startmenu       startmenu.swf       Vanilla/startmenu.xml)
Add_SWF(console         console.swf         Vanilla/console.xml)

Add_SWF(bookmenu
    bookmenu.swf
    Vanilla/bookmenu.xml
    Vanilla/BookBottomBar.as
)

Add_SWF(messagebox
    messagebox.swf
    Vanilla/messagebox.xml
    Vanilla/MessageBox.as
)

Add_SWF(dialoguemenu
    dialoguemenu.swf
    Vanilla/dialoguemenu.xml
    Vanilla/DialogueMenu.as
    Vanilla/DialogueCenteredList.as
)

Add_SWF(lockpickingmenu lockpickingmenu.swf Vanilla/lockpickingmenu.xml)
Add_SWF(loadingmenu     loadingmenu.swf     Vanilla/loadingmenu.xml)
Add_SWF(loadwaitspinner loadwaitspinner.swf Vanilla/loadwaitspinner.xml)

Add_SWF(racesex_menu
    racesex_menu.swf
    Vanilla/racesex_menu.xml
    Vanilla/RaceSexPanels.as
    Vanilla/RaceWidePanel.as
)

Add_SWF(trainingmenu    trainingmenu.swf    Vanilla/trainingmenu.xml)
Add_SWF(tutorialmenu    tutorialmenu.swf    Vanilla/tutorialmenu.xml)
Add_SWF(levelupmenu     levelupmenu.swf     Vanilla/levelupmenu.xml)
Add_SWF(kinectmenu      kinectmenu.swf      Vanilla/kinectmenu.xml)
Add_SWF(fadermenu       fadermenu.swf       Vanilla/fadermenu.xml)
Add_SWF(bethesdanetlogin bethesdanetlogin.swf Vanilla/bethesdanetlogin.xml)
Add_SWF(creationclubmenu creationclubmenu.swf Vanilla/creationclubmenu.xml)
Add_SWF(creditsmenu     creditsmenu.swf     Vanilla/creditsmenu.xml)

Add_SWF(streaminginstall
    streaminginstall.swf
    Vanilla/streaminginstall.xml
    Vanilla/StreamingInstall.as
)

Add_SWF(book            book.swf            Vanilla/book.xml)
Add_SWF(cursormenu      cursormenu.swf      Vanilla/cursormenu.xml)
Add_SWF(safezone        safezone.swf        Vanilla/safezone.xml)
Add_SWF(sharedcomponents sharedcomponents.swf Vanilla/sharedcomponents.xml)
Add_SWF(textentry       textentry.swf       Vanilla/textentry.xml)
Add_SWF(titles          titles.swf          Vanilla/titles.xml)

Add_SWF(tweenmenu
    tweenmenu.swf
    Vanilla/tweenmenu.xml
    TweenMenu/TweenMenu.as
)

Add_SWF(widgetoverlay   widgetoverlay.swf   Vanilla/widgetoverlay.xml)
