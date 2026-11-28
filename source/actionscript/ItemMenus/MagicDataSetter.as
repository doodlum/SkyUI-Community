class MagicDataSetter extends ItemcardDataExtender
{
  /* PRIVATE VARIABLES */

    private var _defaultEnabledColor: Number;
    private var _defaultDisabledColor: Number;


  /* INITIALIZATION */

    public function MagicDataSetter(a_configAppearance: Object)
    {
        super();
        this._defaultEnabledColor = a_configAppearance.colors.text.enabled;
        this._defaultDisabledColor = a_configAppearance.colors.text.disabled;
    }
    
    
  /* PUBLIC FUNCTIONS */
    
    // @override ItemcardDataExtender
    public function processEntry(a_entryObject: Object, a_itemInfo: Object)
    {
        a_entryObject.baseId = a_entryObject.formId & 0x00FFFFFF;
        a_entryObject.type = a_itemInfo.type;

        switch (a_entryObject.type) {
            
            // Shout
            case skyui.defines.Inventory.ICT_SHOUT:
                var recharge: Array = a_itemInfo.spellCost.split(" , ");
                
                if (a_itemInfo.word0) {
                    a_entryObject.word0 = a_itemInfo.word0 + " (" + recharge[0] + ")";
                    a_entryObject.word0Recharge = recharge[0];
                    a_entryObject.word0Color = a_itemInfo.unlocked0 ? this._defaultEnabledColor : this._defaultDisabledColor;
                }
                
                if (a_itemInfo.word1) {
                    a_entryObject.word1 = a_itemInfo.word1 + " (" + recharge[1] + ")";
                    a_entryObject.word1Recharge = recharge[1];
                    a_entryObject.word1Color = a_itemInfo.unlocked1 ? this._defaultEnabledColor : this._defaultDisabledColor;
                }
                
                if (a_itemInfo.word2) {
                    a_entryObject.word2 = a_itemInfo.word2 + " (" + recharge[2] + ")";
                    a_entryObject.word2Recharge = recharge[2];
                    a_entryObject.word2Color = a_itemInfo.unlocked2 ? this._defaultEnabledColor : this._defaultDisabledColor;
                }
                break;
            
            // Active effect
            case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
                if (a_itemInfo.timeRemaining != undefined && a_itemInfo.timeRemaining > 0) {
        
                    var s: Number = Math.floor(a_itemInfo.timeRemaining);
                    var m: Number = 0;
                    var h: Number = 0;
                    var d: Number = 0;
                    
                    if (s >= 60) {
                        m = Math.floor(s / 60);
                        s %= 60;
                    }
                    if  (m >= 60) {
                        h = Math.floor(m / 60);
                        m %= 60;
                    }
                    if  (h >= 24) {
                        d = Math.floor(h / 24);
                        h %= 24;
                    }
                    
                    var dayStr = skyui.util.Translator.translate("$d");
                    var hourStr = skyui.util.Translator.translate("$h");
                    var minStr = skyui.util.Translator.translate("$m");
                    var secStr = skyui.util.Translator.translate("$s");

                    var result = "";

                    if (d > 0)
                        result += d + dayStr + " ";

                    if (h > 0 || d > 0)
                        result += h + hourStr + " ";

                    if (m > 0 || h > 0 || d > 0)
                        result += m + minStr + " ";

                    result += s + secStr;

                    a_entryObject.timeRemainingDisplay = result;
                }
                break;

            // Spell
            case skyui.defines.Inventory.ICT_SPELL:
                a_entryObject.infoCastLevel = a_itemInfo.castLevel;
                a_entryObject.infoSchoolName = a_itemInfo.magicSchoolName;
                
                // 0 -> "-"
                a_entryObject.duration = (a_entryObject.duration > 0) ? (Math.round(a_entryObject.duration * 100) / 100) : null;
                a_entryObject.magnitude = (a_entryObject.magnitude > 0) ? (Math.round(a_entryObject.magnitude * 100) / 100) : null;
                
                var spellCost = a_itemInfo.spellCost;
                a_entryObject.infoSpellCost = spellCost;
            
                if (spellCost != 0 && a_itemInfo.castTime == 0)
                    a_entryObject.spellCostDisplay = spellCost + "/s";
                else
                    a_entryObject.spellCostDisplay = spellCost;
                    
                break;

            //Power
            case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
            default:
                a_entryObject.skillLevel = null;	// Sent by SKSE, we don't want it for powers
                a_entryObject.infoSpellCost = a_itemInfo.spellCost;	// For lesser powers
                
                break;
        }
    }
}
