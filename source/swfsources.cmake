macro(Add_SWF _TARGET_NAME _SWF_REL _XML_PATH)
    set(_BASE_SWF "${CMAKE_CURRENT_BINARY_DIR}/interface/base/${_SWF_REL}")
    set(_FINAL_SWF "${CMAKE_CURRENT_BINARY_DIR}/interface/${_SWF_REL}")

    # Rebuild base from XML
    Add_XML_Base(
        OUTPUT_SWF "${_BASE_SWF}"
        XML_PATH   "${_XML_PATH}"
    )

    # Inject ActionScript sources into that base
    Add_AS(
        TARGET_NAME  AS_${_TARGET_NAME}
        SWF_REL      "${_SWF_REL}"
        SWF_INPUT    "${_BASE_SWF}"
        SWF_OUTPUT   "${_FINAL_SWF}"
        SOURCES      ${ARGN}
    )

    list(APPEND AS_TARGETS           AS_${_TARGET_NAME})
    list(APPEND SWF_COMPILED_OUTPUTS ${AS_${_TARGET_NAME}_OUTPUT})
endmacro()

Add_SWF(bartermenu
    bartermenu.swf
    bartermenu.xml
    Common/skyui/defines/Actor.as
    Common/skyui/defines/Armor.as
    Common/skyui/defines/Form.as
    Common/skyui/defines/Input.as
    Common/skyui/defines/Inventory.as
    Common/skyui/defines/Item.as
    Common/skyui/defines/Magic.as
    Common/skyui/defines/Material.as
    Common/skyui/defines/Weapon.as
    Common/skyui/filter/ItemTypeFilter.as
    Common/skyui/filter/NameFilter.as
    Common/skyui/filter/SortFilter.as
    ItemMenus/BarterDataSetter.as
    ItemMenus/BarterMenu.as
    ItemMenus/BottomBar.as
    ItemMenus/CategoryList.as
    ItemMenus/InventoryDataSetter.as
    ItemMenus/InventoryIconSetter.as
    ItemMenus/InventoryLists.as
    ItemMenus/ItemMenu.as
    ItemMenus/ItemcardDataExtender.as
    Vanilla/Components/Meter.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(bookmenu
    bookmenu.swf
    bookmenu.xml
    ItemMenus/BottomBar.as
    Vanilla/BookBottomBar.as
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/Proxy.as
)

Add_SWF(console
    console.swf
    console.xml
    Vanilla/Console.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(containermenu
    containermenu.swf
    containermenu.xml
    Common/skyui/defines/Actor.as
    Common/skyui/defines/Armor.as
    Common/skyui/defines/Form.as
    Common/skyui/defines/Input.as
    Common/skyui/defines/Inventory.as
    Common/skyui/defines/Item.as
    Common/skyui/defines/Magic.as
    Common/skyui/defines/Material.as
    Common/skyui/defines/Weapon.as
    Common/skyui/filter/ItemTypeFilter.as
    Common/skyui/filter/NameFilter.as
    Common/skyui/filter/SortFilter.as
    ItemMenus/BottomBar.as
    ItemMenus/CategoryList.as
    ItemMenus/ContainerMenu.as
    ItemMenus/InventoryDataSetter.as
    ItemMenus/InventoryIconSetter.as
    ItemMenus/InventoryLists.as
    ItemMenus/ItemMenu.as
    ItemMenus/ItemcardDataExtender.as
    Vanilla/Components/Meter.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(craftingmenu
    craftingmenu.swf
    craftingmenu.xml
    Common/skyui/defines/Actor.as
    Common/skyui/defines/Armor.as
    Common/skyui/defines/Form.as
    Common/skyui/defines/Input.as
    Common/skyui/defines/Inventory.as
    Common/skyui/defines/Item.as
    Common/skyui/defines/Magic.as
    Common/skyui/defines/Material.as
    Common/skyui/defines/Weapon.as
    Common/skyui/filter/ItemTypeFilter.as
    Common/skyui/filter/NameFilter.as
    Common/skyui/filter/SortFilter.as
    CraftingMenu/CraftingDataSetter.as
    CraftingMenu/CraftingIconSetter.as
    CraftingMenu/CraftingListEntry.as
    CraftingMenu/CraftingLists.as
    CraftingMenu/CraftingMenu.as
    CraftingMenu/IconTabList.as
    CraftingMenu/IconTabListEntry.as
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(creditsmenu
    creditsmenu.swf
    creditsmenu.xml
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/CreditsMenu.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/Proxy.as
)

Add_SWF(dialoguemenu
    dialoguemenu.swf
    dialoguemenu.xml
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/DialogueCenteredList.as
    Vanilla/DialogueMenu.as
    Vanilla/Shared/BSScrollingList.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/ButtonMapping.as
    Vanilla/Shared/CenteredScrollingList.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/ListFilterer.as
    Vanilla/Shared/Proxy.as
)

Add_SWF(exported_skyui_widgetloader
    exported/skyui/widgetloader.swf
    exported/skyui/widgetloader.xml
    Common/skyui/defines/Input.as
    HUDWidgets/WidgetLoader.as
)

Add_SWF(exported_skyui_icons_effect_psychosteve
    exported/skyui/icons_effect_psychosteve.swf
    exported/skyui/icons_effect_psychosteve.xml
)

Add_SWF(exported_widgets_skyui_activeeffects
    exported/widgets/skyui/activeeffects.swf
    exported/widgets/skyui/activeeffects.xml
    Common/skyui/defines/Actor.as
    Common/skyui/defines/Magic.as
    HUDWidgets/skyui/widgets/WidgetBase.as
    HUDWidgets/skyui/widgets/activeeffects/ActiveEffect.as
    HUDWidgets/skyui/widgets/activeeffects/ActiveEffectsGroup.as
    HUDWidgets/skyui/widgets/activeeffects/ActiveEffectsWidget.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(fadermenu
    fadermenu.swf
    fadermenu.xml
    Vanilla/FaderMenu.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(favoritesmenu
    favoritesmenu.swf
    favoritesmenu.xml
    Common/skyui/defines/Actor.as
    Common/skyui/defines/Armor.as
    Common/skyui/defines/Form.as
    Common/skyui/defines/Input.as
    Common/skyui/defines/Item.as
    Common/skyui/defines/Weapon.as
    Common/skyui/filter/ItemTypeFilter.as
    Common/skyui/filter/SortFilter.as
    FavoritesMenu/FavoritesIconSetter.as
    FavoritesMenu/FavoritesListEntry.as
    FavoritesMenu/FavoritesMenu.as
    FavoritesMenu/FilterDataExtender.as
    FavoritesMenu/GroupButton.as
    FavoritesMenu/GroupDataExtender.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(giftmenu
    giftmenu.swf
    giftmenu.xml
    Common/skyui/defines/Actor.as
    Common/skyui/defines/Armor.as
    Common/skyui/defines/Form.as
    Common/skyui/defines/Input.as
    Common/skyui/defines/Inventory.as
    Common/skyui/defines/Item.as
    Common/skyui/defines/Magic.as
    Common/skyui/defines/Material.as
    Common/skyui/defines/Weapon.as
    Common/skyui/filter/ItemTypeFilter.as
    Common/skyui/filter/NameFilter.as
    Common/skyui/filter/SortFilter.as
    ItemMenus/BottomBar.as
    ItemMenus/CategoryList.as
    ItemMenus/GiftMenu.as
    ItemMenus/InventoryDataSetter.as
    ItemMenus/InventoryIconSetter.as
    ItemMenus/InventoryLists.as
    ItemMenus/ItemMenu.as
    ItemMenus/ItemcardDataExtender.as
    Vanilla/Components/Meter.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(hudmenu
    hudmenu.swf
    hudmenu.xml
    Vanilla/AnimatedLetter.as
    Vanilla/Components/BlinkOnDemandMeter.as
    Vanilla/Components/BlinkOnDemandPenaltyMeter.as
    Vanilla/Components/BlinkOnEmptyMeter.as
    Vanilla/Components/BlinkOnEmptyPenaltyMeter.as
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Components/Meter.as
    Vanilla/Components/UniformTimeMeter.as
    Vanilla/HUDMenu.as
    Vanilla/Messages.as
    Vanilla/ObjectiveText.as
    Vanilla/QuestNotification.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/ButtonTextArtHolder.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/PlatformChangeUser.as
    Vanilla/Shared/Proxy.as
    Vanilla/ShoutMeter.as
)

Add_SWF(inventorymenu
    inventorymenu.swf
    inventorymenu.xml
    Common/skyui/defines/Actor.as
    Common/skyui/defines/Armor.as
    Common/skyui/defines/Form.as
    Common/skyui/defines/Input.as
    Common/skyui/defines/Inventory.as
    Common/skyui/defines/Item.as
    Common/skyui/defines/Magic.as
    Common/skyui/defines/Material.as
    Common/skyui/defines/Weapon.as
    Common/skyui/filter/ItemTypeFilter.as
    Common/skyui/filter/NameFilter.as
    Common/skyui/filter/SortFilter.as
    ItemMenus/BottomBar.as
    ItemMenus/CategoryList.as
    ItemMenus/InventoryDataSetter.as
    ItemMenus/InventoryIconSetter.as
    ItemMenus/InventoryLists.as
    ItemMenus/InventoryMenu.as
    ItemMenus/ItemMenu.as
    ItemMenus/ItemcardDataExtender.as
)

Add_SWF(levelupmenu
    levelupmenu.swf
    levelupmenu.xml
    Vanilla/LevelUpMenu.as
)

Add_SWF(loadingmenu
    loadingmenu.swf
    loadingmenu.xml
    Vanilla/Components/Meter.as
    Vanilla/LoadingMenu.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(loadwaitspinner
    loadwaitspinner.swf
    loadwaitspinner.xml
    Vanilla/LoadWaitSpinner.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(lockpickingmenu
    lockpickingmenu.swf
    lockpickingmenu.xml
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Components/Meter.as
    Vanilla/LockpickingMenu.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/Proxy.as
)

Add_SWF(magicmenu
    magicmenu.swf
    magicmenu.xml
    Common/skyui/defines/Actor.as
    Common/skyui/defines/Armor.as
    Common/skyui/defines/Form.as
    Common/skyui/defines/Input.as
    Common/skyui/defines/Inventory.as
    Common/skyui/defines/Item.as
    Common/skyui/defines/Magic.as
    Common/skyui/defines/Material.as
    Common/skyui/defines/Weapon.as
    Common/skyui/filter/ItemTypeFilter.as
    Common/skyui/filter/NameFilter.as
    Common/skyui/filter/SortFilter.as
    ItemMenus/BottomBar.as
    ItemMenus/CategoryList.as
    ItemMenus/InventoryLists.as
    ItemMenus/ItemMenu.as
    ItemMenus/ItemcardDataExtender.as
    ItemMenus/MagicDataSetter.as
    ItemMenus/MagicIconSetter.as
    ItemMenus/MagicMenu.as
)

Add_SWF(map
    map.swf
    map.xml
    MapMenu/Map/LocalMap.as
    MapMenu/Map/LocationFinder.as
    MapMenu/Map/LocationListEntry.as
    MapMenu/Map/MapMarker.as
    MapMenu/Map/MapMenu.as
    MapMenu/Map/MarkerDescription.as
)

Add_SWF(skyui_mapfinderpanel
    skyui/mapfinderpanel.swf
    skyui/mapfinderpanel.xml
    Common/skyui/defines/Input.as
    Common/skyui/filter/NameFilter.as
    Common/skyui/filter/SortFilter.as
    MapMenu/Map/LocationFinder.as
    MapMenu/Map/LocationListEntry.as
)

Add_SWF(messagebox
    messagebox.swf
    messagebox.xml
    Vanilla/MessageBox.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(quest_journal
    quest_journal.swf
    quest_journal.xml
    Common/skyui/defines/Input.as
    PauseMenu/InputMappingList.as
    PauseMenu/JournalBottomBar.as
    PauseMenu/JournalSaveLoadList.as
    PauseMenu/ObjectiveScrollingList.as
    PauseMenu/OptionsList.as
    PauseMenu/QuestCenteredList.as
    PauseMenu/Quest_Journal.as
    PauseMenu/QuestsPage.as
    Vanilla/SaveLoadPanel.as
    PauseMenu/SettingsOptionItem.as
    PauseMenu/StatsList.as
    PauseMenu/StatsPage.as
    PauseMenu/SystemPage.as
    Vanilla/Components/Meter.as
    Vanilla/Shared/BSScrollingList.as
    Vanilla/Shared/ButtonTextArtHolder.as
    Vanilla/Shared/CenteredScrollingList.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/ListFilterer.as
)

Add_SWF(racesex_menu
    racesex_menu.swf
    racesex_menu.xml
    ItemMenus/CategoryList.as
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/FilteredList.as
    Vanilla/RaceNarrowPanel.as
    Vanilla/RaceSexPanels.as
    Vanilla/RaceWidePanel.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/CenteredList.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/Proxy.as
    Vanilla/Shared/VerticalCenteredList.as
)

Add_SWF(sharedcomponents
    sharedcomponents.swf
    sharedcomponents.xml
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Shared/ButtonChange.as
)

Add_SWF(skyui_bottombar
    skyui/bottombar.swf
    skyui/bottombar.xml
    Common/skyui/defines/Input.as
    Common/skyui/defines/Inventory.as
    ItemMenus/BottomBar.as
    Vanilla/Components/Meter.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(skyui_buttonart
    skyui/buttonart.swf
    skyui/buttonart.xml
)

Add_SWF(skyui_configpanel
    skyui/configpanel.swf
    skyui/configpanel.xml
    Common/skyui/defines/Input.as
    ModConfigPanel/ColorDialog.as
    ModConfigPanel/ConfigPanel.as
    ModConfigPanel/MenuDialog.as
    ModConfigPanel/MessageDialog.as
    ModConfigPanel/ModListPanel.as
    ModConfigPanel/MultiColumnScrollingList.as
    ModConfigPanel/OptionDialog.as
    ModConfigPanel/OptionsListEntry.as
    ModConfigPanel/SliderDialog.as
    ModConfigPanel/TextInputDialog.as
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/ModListEntry.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(skyui_icons_category_celtic
    skyui/icons_category_celtic.swf
    skyui/icons_category_celtic.xml
)

Add_SWF(skyui_icons_category_curved
    skyui/icons_category_curved.swf
    skyui/icons_category_curved.xml
)

Add_SWF(skyui_icons_category_psychosteve
    skyui/icons_category_psychosteve.swf
    skyui/icons_category_psychosteve.xml
)

Add_SWF(skyui_icons_category_straight
    skyui/icons_category_straight.swf
    skyui/icons_category_straight.xml
)

Add_SWF(skyui_icons_item_psychosteve
    skyui/icons_item_psychosteve.swf
    skyui/icons_item_psychosteve.xml
)

Add_SWF(skyui_inventorylists
    skyui/inventorylists.swf
    skyui/inventorylists.xml
    Common/skyui/defines/Input.as
    Common/skyui/filter/ItemTypeFilter.as
    Common/skyui/filter/NameFilter.as
    Common/skyui/filter/SortFilter.as
    ItemMenus/CategoryList.as
    ItemMenus/CategoryListEntry.as
    ItemMenus/InventoryListEntry.as
    ItemMenus/InventoryLists.as
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(skyui_itemcard
    skyui/itemcard.swf
    skyui/itemcard.xml
    Common/skyui/defines/Input.as
    Common/skyui/defines/Inventory.as
    ItemMenus/ItemCard.as
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Components/Meter.as
    Vanilla/Shared/BSScrollingList.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/CenteredScrollingList.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/ListFilterer.as
)

Add_SWF(skyui_mapmarkerart
    skyui/mapmarkerart.swf
    skyui/mapmarkerart.xml
)

Add_SWF(skyui_mcm_splash
    skyui/mcm_splash.swf
    skyui/mcm_splash.xml
)

Add_SWF(skyui_skyui_splash
    skyui/skyui_splash.swf
    skyui/skyui_splash.xml
    ModConfigPanel/ParticleEmitter.as
    ModConfigPanel/SkyUISplash.as
    ModConfigPanel/SnowEffect.as
)

Add_SWF(sleepwaitmenu
    sleepwaitmenu.swf
    sleepwaitmenu.xml
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/Proxy.as
    Vanilla/SleepWaitMenu.as
)

Add_SWF(startmenu
    startmenu.swf
    startmenu.xml
    Vanilla/SaveLoadPanel.as
    Vanilla/BethesdaNetLogin.as
    Vanilla/BottomButtons.as
    Vanilla/CharacterSelectHintButtons.as
    Vanilla/MainSaveLoadList.as
    Vanilla/Shared/BSScrollingList.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/CenteredScrollingList.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/ListFilterer.as
    Vanilla/Shared/Proxy.as
    Vanilla/StartMenu.as
)

Add_SWF(statsmenu
    statsmenu.swf
    statsmenu.xml
    Vanilla/AnimatedSkillText.as
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Components/Meter.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/Proxy.as
    Vanilla/StatsMenu.as
)

Add_SWF(textentry
    textentry.swf
    textentry.xml
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/Proxy.as
    Vanilla/TextEntryField.as
)

Add_SWF(titles
    titles.swf
    titles.xml
)

Add_SWF(trainingmenu
    trainingmenu.swf
    trainingmenu.xml
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Components/Meter.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/Proxy.as
    Vanilla/TrainingMenu.as
)

Add_SWF(tutorialmenu
    tutorialmenu.swf
    tutorialmenu.xml
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/ButtonMapping.as
    Vanilla/Shared/ButtonTextArtHolder.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/Proxy.as
    Vanilla/TutorialMenu.as
)

Add_SWF(tweenmenu
    tweenmenu.swf
    tweenmenu.xml
    TweenMenu/TweenMenu.as
    Vanilla/Components/CrossPlatformButtons.as
    Vanilla/Components/Meter.as
    Vanilla/Shared/ButtonChange.as
    Vanilla/Shared/GlobalFunc.as
    Vanilla/Shared/Proxy.as
)