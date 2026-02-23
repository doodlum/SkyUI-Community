class skyui.filter.NameFilter implements skyui.filter.IFilter
{
   var dispatchEvent;
   var nameAttribute = "text";
   var _filterText = "";
   function NameFilter()
   {
      gfx.events.EventDispatcher.initialize(this);
   }
   function get filterText()
   {
      return this._filterText;
   }
   function set filterText(a_filterText)
   {
      a_filterText = a_filterText.toLowerCase();
      if(a_filterText == this._filterText)
      {
         return;
      }
      this._filterText = a_filterText;
      this.dispatchEvent({type:"filterChange"});
   }
   function applyFilter(a_filteredList)
   {
      if(this._filterText == undefined || this._filterText == "")
      {
         return undefined;
      }
      var _loc2_ = 0;
      while(_loc2_ < a_filteredList.length)
      {
         if(!this.isMatch(a_filteredList[_loc2_]))
         {
            a_filteredList.splice(_loc2_,1);
            _loc2_ = _loc2_ - 1;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   // Lowercases a character code in the SWF's remapped encoding.
   // AS2's toLowerCase() only handles ASCII; this covers ASCII A-Z and all
   // Cyrillic chars as remapped by GlobalFunctions.mapUnicodeChar.
   static function toLowerRemapped(a_code)
   {
      // ASCII: A-Z (65-90) → a-z
      if(a_code >= 65 && a_code <= 90)
         return a_code + 32;
      // Main Cyrillic block: А(192)-Я(223) → а(224)-я(255)
      if(a_code >= 192 && a_code <= 223)
         return a_code + 32;
      // Special Cyrillic chars (remapped values from mapUnicodeChar):
      if(a_code == 168) return 184; // Ё → ё
      if(a_code == 170) return 186; // Є → є
      if(a_code == 163) return 188; // Ј → ј
      if(a_code == 175) return 191; // Ї → ї
      if(a_code == 178) return 179; // І → і
      if(a_code == 189) return 190; // Ѕ → ѕ
      if(a_code == 161) return 162; // Ү → ү
      if(a_code == 165) return 164; // Ғ → ғ
      return a_code;
   }
   // Substring search with proper encoding and case handling for all scripts.
   // Entry text uses the SWF's remapped Cyrillic encoding (192-255).
   // Filter text uses Unicode (from keyboard input); mapUnicodeChar converts it.
   function isMatch(a_entry)
   {
      var entryText = a_entry[this.nameAttribute];
      var filterText = this._filterText;
      var entryLen = entryText.length;
      var filterLen = filterText.length;
      var ei = 0;
      var fi;
      while(ei <= entryLen - filterLen)
      {
         fi = 0;
         while(fi < filterLen)
         {
            if(skyui.filter.NameFilter.toLowerRemapped(entryText.charCodeAt(ei + fi)) != skyui.filter.NameFilter.toLowerRemapped(skyui.util.GlobalFunctions.mapUnicodeChar(filterText.charCodeAt(fi))))
               break;
            fi++;
         }
         if(fi == filterLen)
            return true;
         ei++;
      }
      return false;
   }
}
