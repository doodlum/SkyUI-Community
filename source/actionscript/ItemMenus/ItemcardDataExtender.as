// @abstract
class ItemcardDataExtender implements skyui.components.list.IListProcessor
{
  /* PRIVATE VARIABLES */

    private var _itemInfo: Object;
    private var _requestItemInfo: Function;
    
    
  /* INITIALIZATION */
    
    public function ItemcardDataExtender()
    {
        this._requestItemInfo = function(a_target: Object, a_index: Number)
        {
            var oldIndex = this._selectedIndex;
            this._selectedIndex = a_index;
            gfx.io.GameDelegate.call("RequestItemCardInfo", [], a_target, "updateItemInfo");
            this._selectedIndex = oldIndex;
        };
    }
    
    
  /* PUBLIC FUNCTIONS */
    
    public function updateItemInfo(a_updateObj: Object)
    {
        this._itemInfo = a_updateObj;
    }
    
    // @override IListProcessor
    public function processList(a_list: BasicList)
    {
        var entryList = a_list.entryList;
        
        for (var i = 0; i < entryList.length; i++) {
            var e = entryList[i];
            if (e.skyui_itemDataProcessed || e.filterFlag == 0)
                continue;
                
            e.skyui_itemDataProcessed = true;
            
            // Fix wrong property names
            this.fixSKSEExtendedObject(e);

            // Hack to retrieve itemcard info
            this._requestItemInfo.apply(a_list, [this, i]);
            this.processEntry(e, this._itemInfo);
        }
    }


  /* PRIVATE FUNCTIONS */
    
    // @abstract
    private function processEntry(a_entryObject: Object, a_itemInfo: Object) {}

    private function fixSKSEExtendedObject(a_extendedObject: Object)
    {
        if (a_extendedObject.formType == undefined)
            return;

        switch(a_extendedObject.formType) {
            case skyui.defines.Form.TYPE_SPELL:
            case skyui.defines.Form.TYPE_SCROLLITEM:
            case skyui.defines.Form.TYPE_INGREDIENT:
            case skyui.defines.Form.TYPE_POTION:
            case skyui.defines.Form.TYPE_EFFECTSETTING:

                // school is sent as subType
                if (a_extendedObject.school == undefined && a_extendedObject.subType != undefined) {
                    a_extendedObject.school = a_extendedObject.subType;
                    delete(a_extendedObject.subType);
                }

                // resistance is sent as magicType
                if (a_extendedObject.resistance == undefined && a_extendedObject.magicType != undefined) {
                    a_extendedObject.resistance = a_extendedObject.magicType;
                    delete(a_extendedObject.magicType);
                }

                // primaryValue is sent as actorValue
                /* // Ignore
                if (a_extendedObject.primaryValue == undefined && a_extendedObject.actorValue != undefined) {
                    a_extendedObject.primaryValue = a_extendedObject.actorValue;
                    delete(a_extendedObject.actorValue);
                }
                */
                break;

            case skyui.defines.Form.TYPE_WEAPON:
                // weaponType is sent as subType
                if (a_extendedObject.weaponType == undefined && a_extendedObject.subType != undefined) {
                    a_extendedObject.weaponType = a_extendedObject.subType;
                    delete(a_extendedObject.subType);
                }
                break;

            case skyui.defines.Form.TYPE_BOOK:
                // (SKSE < 1.6.6) flags and bookType (and some padding) are sent as one UInt32 bookType
                if (a_extendedObject.flags == undefined && a_extendedObject.bookType != undefined) {
                    var oldBookType: Number = a_extendedObject.bookType;
                    a_extendedObject.bookType	= (oldBookType & 0xFF00) >>> 8;
                    a_extendedObject.flags		= (oldBookType & 0x00FF);
                }
                break;

            default:
                break;
        }

    }
}
