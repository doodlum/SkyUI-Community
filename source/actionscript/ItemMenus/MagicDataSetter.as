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
      var _loc6_;
      var _loc8_;
      var _loc5_;
      var _loc4_;
      var _loc7_;
      var _loc9_;
      switch(a_entryObject.type)
      {
         case skyui.defines.Inventory.ICT_SHOUT:
            _loc6_ = a_itemInfo.spellCost.split(" , ");
            if(a_itemInfo.word0)
            {
               a_entryObject.word0 = a_itemInfo.word0 + " (" + _loc6_[0] + ")";
               a_entryObject.word0Recharge = _loc6_[0];
               a_entryObject.word0Color = !a_itemInfo.unlocked0 ? this._defaultDisabledColor : this._defaultEnabledColor;
            }
            if(a_itemInfo.word1)
            {
               a_entryObject.word1 = a_itemInfo.word1 + " (" + _loc6_[1] + ")";
               a_entryObject.word1Recharge = _loc6_[1];
               a_entryObject.word1Color = !a_itemInfo.unlocked1 ? this._defaultDisabledColor : this._defaultEnabledColor;
            }
            if(a_itemInfo.word2)
            {
               a_entryObject.word2 = a_itemInfo.word2 + " (" + _loc6_[2] + ")";
               a_entryObject.word2Recharge = _loc6_[2];
               a_entryObject.word2Color = !a_itemInfo.unlocked2 ? this._defaultDisabledColor : this._defaultEnabledColor;
               return;
            }
            return;
            break;
         case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
            if(a_itemInfo.timeRemaining != undefined && a_itemInfo.timeRemaining > 0)
            {
               _loc8_ = Math.round(a_itemInfo.timeRemaining);
               _loc5_ = 0;
               _loc4_ = 0;
               _loc7_ = 0;
               if(_loc8_ >= 60)
               {
                  _loc5_ = Math.floor(_loc8_ / 60);
                  _loc8_ %= 60;
               }
               if(_loc5_ >= 60)
               {
                  _loc4_ = Math.floor(_loc5_ / 60);
                  _loc5_ %= 60;
               }
               if(_loc4_ >= 24)
               {
                  _loc7_ = Math.floor(_loc4_ / 24);
                  _loc4_ %= 24;
               }
               a_entryObject.timeRemainingDisplay = (_loc7_ == 0 ? "" : _loc7_ + "d ") + (!(_loc4_ != 0 || _loc7_) ? "" : _loc4_ + "h ") + (!(_loc5_ != 0 || _loc7_ || _loc4_) ? "" : _loc5_ + "m ") + (_loc8_ + "s");
               return;
            }
            return;
            break;
         case skyui.defines.Inventory.ICT_SPELL:
            a_entryObject.infoCastLevel = a_itemInfo.castLevel;
            a_entryObject.infoSchoolName = a_itemInfo.magicSchoolName;
            a_entryObject.duration = a_entryObject.duration <= 0 ? null : Math.round(a_entryObject.duration * 100) / 100;
            a_entryObject.magnitude = a_entryObject.magnitude <= 0 ? null : Math.round(a_entryObject.magnitude * 100) / 100;
            _loc9_ = a_itemInfo.spellCost;
            a_entryObject.infoSpellCost = _loc9_;
            if(_loc9_ != 0 && a_itemInfo.castTime == 0)
            {
               a_entryObject.spellCostDisplay = _loc9_ + "/s";
               return;
            }
            a_entryObject.spellCostDisplay = _loc9_;
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
