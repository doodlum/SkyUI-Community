macro(Add_SWF _TARGET_NAME _SWF_REL _XML_PATH)
    set(_SKIP_IN_RELEASE FALSE)
    set(_RAW_SOURCES ${ARGN})
    set(_SOURCES "")
    
    # A stack to keep track of the current path prefix
    set(_PREFIX_STACK "")
    set(_CURRENT_PREFIX "")
    set(_LAST_TOKEN "")

    foreach(_token IN LISTS _RAW_SOURCES)
        if("${_token}" STREQUAL "SKIP_IN_RELEASE")
            set(_SKIP_IN_RELEASE TRUE)
            set(_LAST_TOKEN "") # Keywords cannot be directory names
        elseif("${_token}" STREQUAL "{")
            # Validation: Check if the preceding token is a valid folder name
            if("${_LAST_TOKEN}" STREQUAL "" OR "${_LAST_TOKEN}" STREQUAL "{" OR "${_LAST_TOKEN}" STREQUAL "}")
                message(FATAL_ERROR "Add_SWF(${_TARGET_NAME}): '{' must be preceded by a directory name. Found: '${_LAST_TOKEN}'")
            endif()

            # The directory name was added to _SOURCES in the 'else' branch; remove it
            list(LENGTH _SOURCES _len)
            if(_len GREATER 0)
                math(EXPR _last_idx "${_len} - 1")
                list(REMOVE_AT _SOURCES ${_last_idx})
            endif()
            
            list(APPEND _PREFIX_STACK "${_LAST_TOKEN}")
            string(REPLACE ";" "/" _CURRENT_PREFIX "${_PREFIX_STACK}")
            set(_LAST_TOKEN "") # Reset to prevent nested push of same token
        elseif("${_token}" STREQUAL "}")
            # Validation: Check for stack underflow
            list(LENGTH _PREFIX_STACK _len)
            if(_len EQUAL 0)
                message(FATAL_ERROR "Add_SWF(${_TARGET_NAME}): Unexpected '}' found without matching '{'.")
            endif()

            # Pop from stack
            math(EXPR _last_idx "${_len} - 1")
            list(REMOVE_AT _PREFIX_STACK ${_last_idx})
            
            if(_PREFIX_STACK)
                string(REPLACE ";" "/" _CURRENT_PREFIX "${_PREFIX_STACK}")
            else()
                set(_CURRENT_PREFIX "")
            endif()
            set(_LAST_TOKEN "") # Reset after closing a block
        else()
            # Regular file or a potential directory name
            if(_CURRENT_PREFIX)
                list(APPEND _SOURCES "${_CURRENT_PREFIX}/${_token}")
            else()
                list(APPEND _SOURCES "${_token}")
            endif()
            set(_LAST_TOKEN "${_token}")
        endif()
    endforeach()

    # Validation: Check for unmatched open braces
    list(LENGTH _PREFIX_STACK _len)
    if(_len GREATER 0)
        message(FATAL_ERROR "Add_SWF(${_TARGET_NAME}): Missing closing '}' for directories: ${_PREFIX_STACK}")
    endif()

    # --- Logic for build starts here ---
    if(NOT (_SKIP_IN_RELEASE AND CMAKE_BUILD_TYPE STREQUAL "Release"))
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
            SOURCES      ${_SOURCES}
        )

        list(APPEND AS_TARGETS           AS_${_TARGET_NAME})
        list(APPEND SWF_COMPILED_OUTPUTS ${AS_${_TARGET_NAME}_OUTPUT})
    else()
        message(STATUS "[Build] Skipping ${_TARGET_NAME} (release build)")
    endif()
endmacro()

Add_SWF(bartermenu
    bartermenu.swf
    bartermenu.xml
    Common/skyui/defines {
        Actor.as
        Armor.as
        Form.as
        Input.as
        Inventory.as
        Item.as
        Magic.as
        Material.as
        Weapon.as
    }
    Common/skyui/filter {
        ItemTypeFilter.as
        NameFilter.as
        SortFilter.as
    }
    ItemMenus {
        BarterDataSetter.as
        BarterMenu.as
        BottomBar.as
        CategoryList.as
        InventoryDataSetter.as
        InventoryIconSetter.as
        InventoryLists.as
        ItemMenu.as
        ItemcardDataExtender.as
    }
    Vanilla {
        Components/Meter.as
        Shared/GlobalFunc.as
    }
)

Add_SWF(bookmenu
    bookmenu.swf
    bookmenu.xml
    ItemMenus/BottomBar.as
    Vanilla {
        BookBottomBar.as
        Components/CrossPlatformButtons.as
        Shared {
            ButtonChange.as
            GlobalFunc.as
            Proxy.as
        }
    }
)

Add_SWF(console
    console.swf
    console.xml
    Vanilla {
        Console.as
        Shared/GlobalFunc.as
    }
)

Add_SWF(containermenu
    containermenu.swf
    containermenu.xml
    Common/skyui/defines {
        Actor.as
        Armor.as
        Form.as
        Input.as
        Inventory.as
        Item.as
        Magic.as
        Material.as
        Weapon.as
    }
    Common/skyui/filter {
        ItemTypeFilter.as
        NameFilter.as
        SortFilter.as
    }
    ItemMenus {
        BottomBar.as
        CategoryList.as
        ContainerMenu.as
        InventoryDataSetter.as
        InventoryIconSetter.as
        InventoryLists.as
        ItemMenu.as
        ItemcardDataExtender.as
    }
    Vanilla {
        Components/Meter.as
        Shared/GlobalFunc.as
    }
)

Add_SWF(craftingmenu
    craftingmenu.swf
    craftingmenu.xml
    Common/skyui/defines {
        Actor.as
        Armor.as
        Form.as
        Input.as
        Inventory.as
        Item.as
        Magic.as
        Material.as
        Weapon.as
    }
    Common/skyui/filter {
        ItemTypeFilter.as
        NameFilter.as
        SortFilter.as
    }
    Common/skyui/components/list {
        BasicListEntry.as
        TabularList.as
        TabularListEntry.as
        SortedListHeader.as
        ScrollingList.as
    }
    CraftingMenu {
        CraftingDataSetter.as
        CraftingIconSetter.as
        CraftingListEntry.as
        CraftingLists.as
        CraftingMenu.as
        IconTabList.as
        IconTabListEntry.as
    }
    Vanilla {
        Components/CrossPlatformButtons.as
        Shared {
            ButtonChange.as
            GlobalFunc.as
        }
    }
)

Add_SWF(creditsmenu
    creditsmenu.swf
    creditsmenu.xml
    Vanilla {
        Components/CrossPlatformButtons.as
        CreditsMenu.as
        Shared {
            ButtonChange.as
            GlobalFunc.as
            Proxy.as
        }
    }
)

Add_SWF(dialoguemenu
    dialoguemenu.swf
    dialoguemenu.xml
    Vanilla {
        Components/CrossPlatformButtons.as
        DialogueCenteredList.as
        DialogueMenu.as
        Shared {
            BSScrollingList.as
            ButtonChange.as
            ButtonMapping.as
            CenteredScrollingList.as
            GlobalFunc.as
            ListFilterer.as
            Proxy.as
        }
    }
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
    Common/skyui/defines {
        Actor.as
        Magic.as
    }
    HUDWidgets/skyui/widgets {
        WidgetBase.as
        activeeffects {
            ActiveEffect.as
            ActiveEffectsGroup.as
            ActiveEffectsWidget.as
        }
    }
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(fadermenu
    fadermenu.swf
    fadermenu.xml
    Vanilla {
        FaderMenu.as
        Shared/GlobalFunc.as
    }
)

Add_SWF(favoritesmenu
    favoritesmenu.swf
    favoritesmenu.xml
    Common/skyui/defines {
        Actor.as
        Armor.as
        Form.as
        Input.as
        Item.as
        Weapon.as
    }
    Common/skyui/filter {
        ItemTypeFilter.as
        SortFilter.as
    }
    FavoritesMenu {
        FavoritesIconSetter.as
        FavoritesListEntry.as
        FavoritesMenu.as
        FilterDataExtender.as
        GroupButton.as
        GroupDataExtender.as
    }
    Vanilla/Shared/GlobalFunc.as
)

Add_SWF(giftmenu
    giftmenu.swf
    giftmenu.xml
    Common/skyui/defines {
        Actor.as
        Armor.as
        Form.as
        Input.as
        Inventory.as
        Item.as
        Magic.as
        Material.as
        Weapon.as
    }
    Common/skyui/filter {
        ItemTypeFilter.as
        NameFilter.as
        SortFilter.as
    }
    ItemMenus {
        BottomBar.as
        CategoryList.as
        GiftMenu.as
        InventoryDataSetter.as
        InventoryIconSetter.as
        InventoryLists.as
        ItemMenu.as
        ItemcardDataExtender.as
    }
    Vanilla {
        Components/Meter.as
        Shared/GlobalFunc.as
    }
)

Add_SWF(hudmenu
    hudmenu.swf
    hudmenu.xml
    Vanilla {
        AnimatedLetter.as
        Components {
            BlinkOnDemandMeter.as
            BlinkOnDemandPenaltyMeter.as
            BlinkOnEmptyMeter.as
            BlinkOnEmptyPenaltyMeter.as
            CrossPlatformButtons.as
            Meter.as
            UniformTimeMeter.as
        }
        HUDMenu.as
        Messages.as
        ObjectiveText.as
        QuestNotification.as
        Shared {
            ButtonChange.as
            ButtonTextArtHolder.as
            GlobalFunc.as
            PlatformChangeUser.as
            Proxy.as
        }
        ShoutMeter.as
    }
)

Add_SWF(inventorymenu
    inventorymenu.swf
    inventorymenu.xml
    Common/skyui/defines {
        Actor.as
        Armor.as
        Form.as
        Input.as
        Inventory.as
        Item.as
        Magic.as
        Material.as
        Weapon.as
    }
    Common/skyui/filter {
        ItemTypeFilter.as
        NameFilter.as
        SortFilter.as
    }
    ItemMenus {
        BottomBar.as
        CategoryList.as
        InventoryDataSetter.as
        InventoryIconSetter.as
        InventoryLists.as
        InventoryMenu.as
        ItemMenu.as
        ItemcardDataExtender.as
    }
)

Add_SWF(levelupmenu
    levelupmenu.swf
    levelupmenu.xml
    Vanilla/LevelUpMenu.as
)

Add_SWF(loadingmenu
    loadingmenu.swf
    loadingmenu.xml
    Vanilla {
        Components/Meter.as
        LoadingMenu.as
        Shared/GlobalFunc.as
    }
)

Add_SWF(loadwaitspinner
    loadwaitspinner.swf
    loadwaitspinner.xml
    Vanilla {
        LoadWaitSpinner.as
        Shared/GlobalFunc.as
    }
)

Add_SWF(lockpickingmenu
    lockpickingmenu.swf
    lockpickingmenu.xml
    Vanilla {
        Components {
            CrossPlatformButtons.as
            Meter.as
        }
        LockpickingMenu.as
        Shared {
            ButtonChange.as
            GlobalFunc.as
            Proxy.as
        }
    }
)

Add_SWF(magicmenu
    magicmenu.swf
    magicmenu.xml
    Common/skyui/defines {
        Actor.as
        Armor.as
        Form.as
        Input.as
        Inventory.as
        Item.as
        Magic.as
        Material.as
        Weapon.as
    }
    Common/skyui/filter {
        ItemTypeFilter.as
        NameFilter.as
        SortFilter.as
    }
    ItemMenus {
        BottomBar.as
        CategoryList.as
        InventoryLists.as
        ItemMenu.as
        ItemcardDataExtender.as
        MagicDataSetter.as
        MagicIconSetter.as
        MagicMenu.as
    }
)

Add_SWF(map
    map.swf
    map.xml
    Common/skyui/defines/Input.as
    Common/skyui/filter {
        NameFilter.as
        SortFilter.as
    }
    MapMenu/Map {
        LocalMap.as
        LocationFinder.as
        LocationListEntry.as
        MapMarker.as
        MapMenu.as
        MarkerDescription.as
    }
)

Add_SWF(messagebox
    messagebox.swf
    messagebox.xml
    Vanilla {
        MessageBox.as
        Shared/GlobalFunc.as
    }
)

Add_SWF(quest_journal
    quest_journal.swf
    quest_journal.xml
    Common/skyui/defines/Input.as
    PauseMenu {
        InputMappingList.as
        JournalBottomBar.as
        JournalSaveLoadList.as
        ObjectiveScrollingList.as
        OptionsList.as
        QuestCenteredList.as
        Quest_Journal.as
        QuestsPage.as
        SettingsOptionItem.as
        StatsList.as
        StatsPage.as
        SystemPage.as
    }
    Vanilla {
        Components/Meter.as
        SaveLoadPanel.as
        Shared {
            BSScrollingList.as
            ButtonTextArtHolder.as
            CenteredScrollingList.as
            GlobalFunc.as
            ListFilterer.as
        }
    }
)

Add_SWF(racesex_menu
    racesex_menu.swf
    racesex_menu.xml
    ItemMenus/CategoryList.as
    Vanilla {
        Components/CrossPlatformButtons.as
        FilteredList.as
        RaceNarrowPanel.as
        RaceSexPanels.as
        RaceWidePanel.as
        Shared {
            ButtonChange.as
            CenteredList.as
            GlobalFunc.as
            Proxy.as
            VerticalCenteredList.as
        }
    }
)

Add_SWF(sharedcomponents
    sharedcomponents.swf
    sharedcomponents.xml
    Vanilla {
        Components/CrossPlatformButtons.as
        Shared/ButtonChange.as
    }
)

Add_SWF(skyui_bottombar
    skyui/bottombar.swf
    skyui/bottombar.xml
    Common/skyui/defines {
        Input.as
        Inventory.as
    }
    ItemMenus/BottomBar.as
    Vanilla {
        Components/Meter.as
        Shared/GlobalFunc.as
    }
)

Add_SWF(skyui_buttonart
    skyui/buttonart.swf
    skyui/buttonart.xml
)

Add_SWF(skyui_configpanel
    skyui/configpanel.swf
    skyui/configpanel.xml
    Common/skyui/defines/Input.as
    ModConfigPanel {
        ColorDialog.as
        ConfigPanel.as
        MenuDialog.as
        MessageDialog.as
        ModListPanel.as
        MultiColumnScrollBar.as
        MultiColumnScrollingList.as
        OptionDialog.as
        OptionsListEntry.as
        SliderDialog.as
        TextInputDialog.as
    }
    Vanilla {
        Components/CrossPlatformButtons.as
        ModListEntry.as
        Shared {
            ButtonChange.as
            GlobalFunc.as
        }
    }
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
    Common/skyui/filter {
        ItemTypeFilter.as
        NameFilter.as
        SortFilter.as
    }
    Common/skyui/components/list {
        BasicListEntry.as
        TabularList.as
        TabularListEntry.as
        SortedListHeader.as
        ScrollingList.as
    }
    ItemMenus {
        CategoryList.as
        CategoryListEntry.as
        InventoryListEntry.as
        InventoryLists.as
    }
    Vanilla {
        Components/CrossPlatformButtons.as
        Shared {
            ButtonChange.as
            GlobalFunc.as
        }
    }
)

Add_SWF(skyui_itemcard
    skyui/itemcard.swf
    skyui/itemcard.xml
    Common/skyui/defines {
        Input.as
        Inventory.as
    }
    ItemMenus/ItemCard.as
    Vanilla {
        Components {
            CrossPlatformButtons.as
            Meter.as
        }
        Shared {
            BSScrollingList.as
            ButtonChange.as
            CenteredScrollingList.as
            GlobalFunc.as
            ListFilterer.as
        }
    }
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
    ModConfigPanel {
        ParticleEmitter.as
        SkyUISplash.as
        SnowEffect.as
    }
)

Add_SWF(sleepwaitmenu
    sleepwaitmenu.swf
    sleepwaitmenu.xml
    Vanilla {
        Components/CrossPlatformButtons.as
        Shared {
            ButtonChange.as
            GlobalFunc.as
            Proxy.as
        }
        SleepWaitMenu.as
    }
)

Add_SWF(startmenu
    startmenu.swf
    startmenu.xml
    Vanilla {
        BethesdaNetLogin.as
        BottomButtons.as
        CharacterSelectHintButtons.as
        MainSaveLoadList.as
        SaveLoadPanel.as
        StartMenu.as
        Shared {
            BSScrollingList.as
            ButtonChange.as
            CenteredScrollingList.as
            GlobalFunc.as
            ListFilterer.as
            Proxy.as
        }
    }
)

Add_SWF(statsmenu
    statsmenu.swf
    statsmenu.xml
    Vanilla {
        AnimatedSkillText.as
        Components {
            CrossPlatformButtons.as
            Meter.as
        }
        Shared {
            ButtonChange.as
            GlobalFunc.as
            Proxy.as
        }
        StatsMenu.as
    }
)

Add_SWF(textentry
    textentry.swf
    textentry.xml
    Vanilla {
        Components/CrossPlatformButtons.as
        Shared {
            ButtonChange.as
            Proxy.as
        }
        TextEntryField.as
    }
)

Add_SWF(titles
    titles.swf
    titles.xml
)

Add_SWF(trainingmenu
    trainingmenu.swf
    trainingmenu.xml
    Vanilla {
        Components {
            CrossPlatformButtons.as
            Meter.as
        }
        Shared {
            ButtonChange.as
            GlobalFunc.as
            Proxy.as
        }
        TrainingMenu.as
    }
)

Add_SWF(tutorialmenu
    tutorialmenu.swf
    tutorialmenu.xml
    Vanilla {
        Components/CrossPlatformButtons.as
        Shared {
            ButtonChange.as
            ButtonMapping.as
            ButtonTextArtHolder.as
            GlobalFunc.as
            Proxy.as
        }
        TutorialMenu.as
    }
)

Add_SWF(tweenmenu
    tweenmenu.swf
    tweenmenu.xml
    TweenMenu/TweenMenu.as
    Vanilla {
        Components {
            CrossPlatformButtons.as
            Meter.as
        }
        Shared {
            ButtonChange.as
            GlobalFunc.as
            Proxy.as
        }
    }
)

# Only for design debug mode
Add_SWF(gfxfontlib
    gfxfontlib.swf
    gfxfontlib.xml
    SKIP_IN_RELEASE
)