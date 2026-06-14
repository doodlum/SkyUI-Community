class MagicIconSetter implements skyui.components.list.IListProcessor
{
  /* PRIVATE VARIABLES */

    private var _noIconColors: Boolean;

  /* INITIALIZATION */

    public function MagicIconSetter(a_configAppearance: Object)
    {
        this._noIconColors = a_configAppearance.icons.item.noColor;
    }


  /* PUBLIC FUNCTIONS */

    // @override IListProcessor
    public function processList(a_list: BasicList)
    {
        var entryList: Array = a_list.entryList;
        
        for (var i: Number = 0; i < entryList.length; i++)
            this.processEntry(entryList[i]);
    }


  /* PRIVATE FUNCTIONS */

    private function processEntry(a_entryObject: Object)
    {
        switch (a_entryObject.type) {
            case skyui.defines.Inventory.ICT_SPELL:
                this.processSpellIcon(a_entryObject);
                break;

            case skyui.defines.Inventory.ICT_SHOUT:
                a_entryObject.iconLabel = "default_shout";
                break;

            case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
                a_entryObject.iconLabel = "default_effect";
                break;

            case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
                a_entryObject.iconLabel = "default_power";
                break;
                
            default:
                break;
        }
        this.processSpellBaseId(a_entryObject);

        if (this._noIconColors && a_entryObject.iconColor != undefined)
            delete(a_entryObject.iconColor);
    }

    private function processSpellIcon(a_entryObject: Object)
    {
        a_entryObject.iconLabel = "default_power";
        // fire rune, actorValue = Health, school = Destruction, resistance = Fire, effectFlags = hostile+detrimental
        switch(a_entryObject.school)
        {
            case skyui.defines.Actor.AV_ALTERATION:
                a_entryObject.iconLabel = "default_alteration";
                break;

            case skyui.defines.Actor.AV_CONJURATION:
                a_entryObject.iconLabel = "default_conjuration";
                break;

            case skyui.defines.Actor.AV_DESTRUCTION:
                a_entryObject.iconLabel = "default_destruction";
                this.processResist(a_entryObject);
                break;

            case skyui.defines.Actor.AV_ILLUSION:
                a_entryObject.iconLabel = "default_illusion";
                break;

            case skyui.defines.Actor.AV_RESTORATION:
                a_entryObject.iconLabel = "default_restoration";
                break;

        }
    }

    private function processResist(a_entryObject: Object)
    {
        if (a_entryObject.resistance == undefined || a_entryObject.resistance == skyui.defines.Actor.AV_NONE)
            return;

        switch(a_entryObject.resistance) {
            case skyui.defines.Actor.AV_FIRERESIST:
                a_entryObject.iconLabel = "magic_fire";
                a_entryObject.iconColor = 0xC73636;
                break;

            case skyui.defines.Actor.AV_ELECTRICRESIST:
                a_entryObject.iconLabel = "magic_shock";
                a_entryObject.iconColor = 0xEAAB00;
                break;

            case skyui.defines.Actor.AV_FROSTRESIST:
                a_entryObject.iconLabel = "magic_frost";
                a_entryObject.iconColor = 0x1FFBFF;
                break;
        }
    }

    function processSpellBaseId(a_entryObject)
    {
        switch(a_entryObject.baseId)
        {
            case 0x38B5:
            case 0x3F52:
            case 0x38B6:
                a_entryObject.iconLabel = "magic_sun";
                a_entryObject.iconColor = 0xFF8700;
                break;
            case 0x1D74B:
                a_entryObject.iconLabel = "misc_remains";
                a_entryObject.iconColor = 0x62A636;
                break;
            case 0x1772D:
                a_entryObject.iconLabel = "magic_wind";
                a_entryObject.iconColor = 0xCDCBC4;
                break;
            case 0x72320:
            case 0x72311:
            case 0x7233B:
                a_entryObject.iconLabel = "magic_fire";
                a_entryObject.iconColor = 0x1FFBFF;
                break;
        }
    }
}
