class MagicDataSetter extends ItemcardDataExtender
{
   var _defaultDisabledColor;
   var _defaultEnabledColor;
   function MagicDataSetter(a_configAppearance)
   {
      super();
      this._defaultEnabledColor = a_configAppearance.colors.text.enabled;
      this._defaultDisabledColor = a_configAppearance.colors.text.disabled;
   }
   function processEntry(a_entryObject, a_itemInfo)
   {
      a_entryObject.baseId = a_entryObject.formId & 0xFFFFFF;
      a_entryObject.type = a_itemInfo.type;
      var recharge;
      var s;
      var m;
      var h;
      var d;
      var spellCost;
      switch (a_entryObject.type)
      {
         case skyui.defines.Inventory.ICT_SHOUT:
            recharge = a_itemInfo.spellCost.split(" , ");
            if (a_itemInfo.word0)
            {
               a_entryObject.word0 = a_itemInfo.word0 + " (" + recharge[0] + ")";
               a_entryObject.word0Recharge = recharge[0];
               a_entryObject.word0Color = !a_itemInfo.unlocked0 ? this._defaultDisabledColor : this._defaultEnabledColor;
            }
            if (a_itemInfo.word1)
            {
               a_entryObject.word1 = a_itemInfo.word1 + " (" + recharge[1] + ")";
               a_entryObject.word1Recharge = recharge[1];
               a_entryObject.word1Color = !a_itemInfo.unlocked1 ? this._defaultDisabledColor : this._defaultEnabledColor;
            }
            if (a_itemInfo.word2)
            {
               a_entryObject.word2 = a_itemInfo.word2 + " (" + recharge[2] + ")";
               a_entryObject.word2Recharge = recharge[2];
               a_entryObject.word2Color = !a_itemInfo.unlocked2 ? this._defaultDisabledColor : this._defaultEnabledColor;
               return;
            }
            return;
            break;
         case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
            if (a_itemInfo.timeRemaining != undefined && a_itemInfo.timeRemaining > 0)
            {
               s = Math.floor(a_itemInfo.timeRemaining);
               m = 0;
               h = 0;
               d = 0;
               if (s >= 60)
               {
                  m = Math.floor(s / 60);
                  s %= 60;
               }
               if (m >= 60)
               {
                  h = Math.floor(m / 60);
                  m %= 60;
               }
               if (h >= 24)
               {
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
               return;
            }
            return;
            break;
         case skyui.defines.Inventory.ICT_SPELL:
            a_entryObject.infoCastLevel = a_itemInfo.castLevel;
            a_entryObject.infoSchoolName = a_itemInfo.magicSchoolName;
            a_entryObject.duration = a_entryObject.duration <= 0 ? null : Math.round(a_entryObject.duration * 100) / 100;
            a_entryObject.magnitude = a_entryObject.magnitude <= 0 ? null : Math.round(a_entryObject.magnitude * 100) / 100;
            spellCost = a_itemInfo.spellCost;
            a_entryObject.infoSpellCost = spellCost;
            if (spellCost != 0 && a_itemInfo.castTime == 0)
            {
               a_entryObject.spellCostDisplay = spellCost + "/s";
               return;
            }
            a_entryObject.spellCostDisplay = spellCost;
            return;
            break;
         case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
         default:
            a_entryObject.skillLevel = null;
            a_entryObject.infoSpellCost = a_itemInfo.spellCost;
            return;
      }
   }
}
