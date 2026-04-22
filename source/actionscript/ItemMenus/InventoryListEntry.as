class InventoryListEntry extends skyui.components.list.TabularListEntry
{
  /* CONSTANTS */

   private static var STATES = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];

  /* PRIVATE VARIABLES */
   
   private var _iconLabel: String;
   private var _iconColor: Number;
   
  /* STAGE ELMENTS */

   public var itemIcon: MovieClip;
   public var equipIcon: MovieClip;
   
   public var bestIcon: MovieClip;
   public var favoriteIcon: MovieClip;
   public var poisonIcon: MovieClip;
   public var stolenIcon: MovieClip;
   public var enchIcon: MovieClip;
   public var readIcon: MovieClip;
   
   
  /* INITIALIZATION */
   
   // @override TabularListEntry
   public function initialize(a_index: Number, a_state: ListState)
   {
      super.initialize();
      
      var iconLoader = new MovieClipLoader();
      iconLoader.addListener(this);
      iconLoader.loadClip(a_state.iconSource, this.itemIcon);
      
      this.itemIcon._visible = false;
      this.equipIcon._visible = false;
      
      for (var i = 0; this["textField" + i] != undefined; i++)
         this["textField" + i]._visible = false;
   }
   
   
  /* PUBLIC FUNCTIONS */
   
   // @override TabularListEntry
   public function setSpecificEntryLayout(a_entryObject: Object, a_state: ListState)
   {
      var iconY = skyui.components.list.TabularList(a_state.list).layout.entryHeight * 0.25;
      var iconSize = skyui.components.list.TabularList(a_state.list).layout.entryHeight * 0.5;
         
      this.bestIcon._height = this.bestIcon._width = iconSize;
      this.favoriteIcon._height = this.favoriteIcon._width = iconSize;
      this.poisonIcon._height = this.poisonIcon._width = iconSize;
      this.stolenIcon._height = this.stolenIcon._width = iconSize;
      this.enchIcon._height = this.enchIcon._width = iconSize;
      this.readIcon._height = this.readIcon._width = iconSize;
         
      this.bestIcon._y = iconY;
      this.favoriteIcon._y = iconY;
      this.poisonIcon._y = iconY;
      this.stolenIcon._y = iconY;
      this.enchIcon._y = iconY;
      this.readIcon._y = iconY;
   }

   // @override TabularListEntry
   public function formatEquipIcon(a_entryField: Object, a_entryObject: Object, a_state: ListState)
   {
      if (a_entryObject != undefined && a_entryObject.equipState != undefined) {
         a_entryField.gotoAndStop(InventoryListEntry.STATES[a_entryObject.equipState]);
      } else {
         a_entryField.gotoAndStop("None");
      }
   }

   // @override TabularListEntry
   public function formatItemIcon(a_entryField: Object, a_entryObject: Object, a_state: ListState)
   {
      this._iconLabel = a_entryObject["iconLabel"] != undefined ? a_entryObject["iconLabel"] : "default_misc";
      this._iconColor = a_entryObject["iconColor"];

      // Could return here if _iconLoaded is false
      a_entryField.gotoAndStop(this._iconLabel);
      this.changeIconColor(MovieClip(a_entryField), this._iconColor);
   }

   // @override TabularListEntry
   public function formatName(a_entryField: Object, a_entryObject: Object, a_state: ListState)
   {
      if (a_entryObject.text == undefined) {
         a_entryField.SetText(" ");
         return;
      }

      // Text
      var text = a_entryObject.text;

      if (a_entryObject.soulLVL != undefined) {
         text = text + " (" + a_entryObject.soulLVL + ")";
      }

      if (a_entryObject.count > 1) {
         text = text + " (" + a_entryObject.count.toString() + ")";
      }

      if (text.length > a_state.maxTextLength) {
         text = text.substr(0, a_state.maxTextLength - 3) + "...";
      }

      a_entryField.autoSize = "left";
      a_entryField.SetText(text);
      
      this.formatColor(a_entryField, a_entryObject, a_state);

      // BestInClass icon
      var iconPos = a_entryField._x + a_entryField._width + 5;

      // All icons have the same size
      var iconSpace = this.bestIcon._width * 1.25;

      if (a_entryObject.bestInClass == true) {
         this.bestIcon._x = iconPos;
         iconPos = iconPos + iconSpace;

         this.bestIcon.gotoAndStop("show");
      } else {
         this.bestIcon.gotoAndStop("hide");
      }

      // Fav icon
      if (a_entryObject.favorite == true) {
         this.favoriteIcon._x = iconPos;
         iconPos = iconPos + iconSpace;
         this.favoriteIcon.gotoAndStop("show");
      } else {
         this.favoriteIcon.gotoAndStop("hide");
      }

      // Poisoned Icon
      if (a_entryObject.isPoisoned == true) {
         this.poisonIcon._x = iconPos;
         iconPos = iconPos + iconSpace;
         this.poisonIcon.gotoAndStop("show");
      } else {
         this.poisonIcon.gotoAndStop("hide");
      }

      // Stolen Icon
      if ((a_entryObject.isStolen == true || a_entryObject.isStealing == true) && a_state.showStolenIcon == true) {
         this.stolenIcon._x = iconPos;
         iconPos = iconPos + iconSpace;
         this.stolenIcon.gotoAndStop("show");
      } else {
         this.stolenIcon.gotoAndStop("hide");
      }

      // Enchanted Icon
      if (a_entryObject.isEnchanted == true) {
         this.enchIcon._x = iconPos;
         iconPos = iconPos + iconSpace;
         this.enchIcon.gotoAndStop("show");
      } else {
         this.enchIcon.gotoAndStop("hide");
      }

      // Enchanted Icon
      if (a_entryObject.isRead == true) {
         this.readIcon._x = iconPos;
         iconPos = iconPos + iconSpace;
         this.readIcon.gotoAndStop("show");
      } else {
         this.readIcon.gotoAndStop("hide");
      }
   }
   
   // @override TabularEntry
   public function formatText(a_entryField: Object, a_entryObject: Object, a_state: ListState)
   {
      this.formatColor(a_entryField, a_entryObject, a_state);
      a_entryField.autoSize = a_entryField.getTextFormat().align;
   }
   
   
  /* PRIVATE FUNCTIONS */

   // @implements MovieClipLoader
   private function onLoadInit(a_icon: MovieClip)
   {
      a_icon.gotoAndStop(this._iconLabel);
      this.changeIconColor(a_icon, this._iconColor);
   }
   
   private function formatColor(a_entryField: Object, a_entryObject: Object, a_state: ListState)
   {
      // Negative Effect
      if (a_entryObject.negativeEffect == true)
         a_entryField.textColor = a_entryObject.enabled == false ? a_state.negativeDisabledColor : a_state.negativeEnabledColor;
         
      // Stolen
      else if (a_entryObject.infoIsStolen == true || a_entryObject.isStealing == true)
         a_entryField.textColor = a_entryObject.enabled == false ? a_state.stolenDisabledColor : a_state.stolenEnabledColor;
         
      // Default
      else
         a_entryField.textColor = a_entryObject.enabled == false ? a_state.defaultDisabledColor : a_state.defaultEnabledColor;
   }
   
   private function changeIconColor(a_icon: MovieClip, a_rgb: Number)
   {
      var element: Object;
      for (var e in a_icon) {
         element = a_icon[e];
         if (element instanceof MovieClip) {
            //Note: Could check if all values of RGBA mult and .rgb are all the same then skip
            var ct: ColorTransform = new ColorTransform();
            var tf: Transform = new Transform(MovieClip(element));
            // Could return here if (a_rgb == tf.colorTransform.rgb && a_rgb != undefined)
            ct.rgb = (a_rgb == undefined)? 0xFFFFFF: a_rgb;
            tf.colorTransform = ct;
            // Shouldn't be necessary to recurse since we don't expect multiple clip depths for an icon
            //this.changeIconColor(element, a_rgb);
         }
      }
   }
}
