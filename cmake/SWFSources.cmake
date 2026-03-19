# ActionScript sources for all SWFs
# This file consolidates the source lists for each SWF.

# ---- Common shared sources ---------------------------------------------------

set(CORE_SOURCES
    ${AS_SOURCE_DIR}/Common/skyui/defines/Actor.as
    ${AS_SOURCE_DIR}/Common/skyui/defines/Armor.as
    ${AS_SOURCE_DIR}/Common/skyui/defines/Form.as
    ${AS_SOURCE_DIR}/Common/skyui/defines/Input.as
    ${AS_SOURCE_DIR}/Common/skyui/defines/Inventory.as
    ${AS_SOURCE_DIR}/Common/skyui/defines/Item.as
    ${AS_SOURCE_DIR}/Common/skyui/defines/Magic.as
    ${AS_SOURCE_DIR}/Common/skyui/defines/Material.as
    ${AS_SOURCE_DIR}/Common/skyui/defines/Weapon.as
    ${AS_SOURCE_DIR}/Common/skyui/filter/ItemTypeFilter.as
    ${AS_SOURCE_DIR}/Common/skyui/filter/NameFilter.as
    ${AS_SOURCE_DIR}/Common/skyui/filter/SortFilter.as
)

set(ITEM_MENU_CORE
    ${CORE_SOURCES}
    ${AS_SOURCE_DIR}/ItemMenus/InventoryDataSetter.as
    ${AS_SOURCE_DIR}/ItemMenus/InventoryIconSetter.as
    ${AS_SOURCE_DIR}/ItemMenus/ItemMenu.as
    ${AS_SOURCE_DIR}/ItemMenus/ItemcardDataExtender.as
)

set(VANILLA_SHARED
    ${AS_SOURCE_DIR}/Vanilla/Shared/GlobalFunc.as
    ${AS_SOURCE_DIR}/Vanilla/Shared/Proxy.as
    ${AS_SOURCE_DIR}/Vanilla/Shared/ButtonChange.as
    ${AS_SOURCE_DIR}/Vanilla/Shared/ButtonMapping.as
)

# ---- Individual SWF sources --------------------------------------------------

# Item Menus
set(bartermenu_SOURCES      ${ITEM_MENU_CORE} ${AS_SOURCE_DIR}/ItemMenus/BarterMenu.as ${AS_SOURCE_DIR}/ItemMenus/BarterDataSetter.as)
set(containermenu_SOURCES   ${ITEM_MENU_CORE} ${AS_SOURCE_DIR}/ItemMenus/ContainerMenu.as)
set(inventorymenu_SOURCES   ${ITEM_MENU_CORE} ${AS_SOURCE_DIR}/ItemMenus/InventoryMenu.as)
set(magicmenu_SOURCES       ${ITEM_MENU_CORE} ${AS_SOURCE_DIR}/ItemMenus/MagicMenu.as)
set(giftmenu_SOURCES        ${ITEM_MENU_CORE} ${AS_SOURCE_DIR}/ItemMenus/GiftMenu.as)

# Crafting
set(craftingmenu_SOURCES
    ${CORE_SOURCES}
    ${AS_SOURCE_DIR}/CraftingMenu/CraftingMenu.as
    ${AS_SOURCE_DIR}/CraftingMenu/CraftingDataSetter.as
    ${AS_SOURCE_DIR}/CraftingMenu/CraftingIconSetter.as
    ${AS_SOURCE_DIR}/CraftingMenu/CraftingListEntry.as
    ${AS_SOURCE_DIR}/CraftingMenu/CraftingLists.as
    ${AS_SOURCE_DIR}/CraftingMenu/CustomConstructDataSetter.as
    ${AS_SOURCE_DIR}/CraftingMenu/IconTabList.as
    ${AS_SOURCE_DIR}/CraftingMenu/IconTabListEntry.as
)

# Favorites
set(favoritesmenu_SOURCES
    ${CORE_SOURCES}
    ${AS_SOURCE_DIR}/FavoritesMenu/FavoritesMenu.as
    ${AS_SOURCE_DIR}/FavoritesMenu/FavoritesIconSetter.as
    ${AS_SOURCE_DIR}/FavoritesMenu/FavoritesListEntry.as
)

# Journal & Pause
set(quest_journal_SOURCES   ${CORE_SOURCES} ${AS_SOURCE_DIR}/PauseMenu/Quest_Journal.as)
set(statsmenu_SOURCES       ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/StatsMenu.as)
set(sleepwaitmenu_SOURCES   ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/SleepWaitMenu.as)
set(startmenu_SOURCES       ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/StartMenu.as)

# Map
set(map_SOURCES             ${CORE_SOURCES} ${AS_SOURCE_DIR}/MapMenu/Map/MapMenu.as)

# MCM
set(modmanager_SOURCES      ${AS_SOURCE_DIR}/ModConfigPanel/ConfigPanel.as)

# HUD & Widgets
set(hudmenu_SOURCES         ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/HUDMenu.as)
set(exported_skyui_widgetloader_SOURCES ${AS_SOURCE_DIR}/HUDWidgets/WidgetLoader.as)
set(exported_widgets_skyui_activeeffects_SOURCES
    ${AS_SOURCE_DIR}/HUDWidgets/skyui/widgets/activeeffects/ActiveEffectsWidget.as
    ${AS_SOURCE_DIR}/HUDWidgets/skyui/widgets/activeeffects/ActiveEffect.as
    ${AS_SOURCE_DIR}/HUDWidgets/skyui/widgets/activeeffects/ActiveEffectsGroup.as
)

# Tween
set(tweenmenu_SOURCES       ${AS_SOURCE_DIR}/TweenMenu/TweenMenu.as)

# Vanilla Menus (minimal/pass-through injection)
set(console_SOURCES         ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/Console.as)
set(bookmenu_SOURCES        ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/BookMenu.as)
set(messagebox_SOURCES      ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/MessageBox.as)
set(dialoguemenu_SOURCES    ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/DialogueMenu.as)
set(lockpickingmenu_SOURCES ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/LockpickingMenu.as)
set(loadingmenu_SOURCES     ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/LoadingMenu.as)
set(loadwaitspinner_SOURCES ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/LoadWaitSpinner.as)
set(racesex_menu_SOURCES    ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/RaceSexPanels.as)
set(trainingmenu_SOURCES    ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/TrainingMenu.as)
set(tutorialmenu_SOURCES    ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/TutorialMenu.as)
set(levelupmenu_SOURCES     ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/LevelUpMenu.as)
set(kinectmenu_SOURCES      ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/KinectMenu.as)
set(fadermenu_SOURCES       ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/FaderMenu.as)
set(bethesdanetlogin_SOURCES ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/BethesdaNetLogin.as)
set(creationclubmenu_SOURCES ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/CreationClubMenu.as)
set(creditsmenu_SOURCES     ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/CreditsMenu.as)
set(streaminginstall_SOURCES ${VANILLA_SHARED} ${AS_SOURCE_DIR}/Vanilla/StreamingInstall.as)
