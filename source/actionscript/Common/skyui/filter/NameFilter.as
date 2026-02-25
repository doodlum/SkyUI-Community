class skyui.filter.NameFilter implements skyui.filter.IFilter
{
    var dispatchEvent;
    var nameAttribute = "text";
    var _filterText = "";
    static var _charMap = undefined;

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
        if(a_filterText == undefined) { a_filterText = ""; }
        if(a_filterText == this._filterText) { return; }
        this._filterText = a_filterText;
        this.dispatchEvent({type:"filterChange"});
    }
    
    function applyFilter(a_filteredList)
    {
        if(this._filterText == undefined || this._filterText == "") return undefined;
        
        var i = 0;
        while(i < a_filteredList.length)
        {
            if(!this.isMatch(a_filteredList[i]))
            {
                a_filteredList.splice(i, 1);
                i--;
            }
            i++;
        }
    }

    static function addRange(chars:Array, targetCode:Number)
    {
        for (var i = 0; i < chars.length; i++)
        {
            this._charMap[chars[i]] = targetCode;
        }
    }

    static function initCharMap()
    {
        if (this._charMap !== undefined) return;
        
        this._charMap = new Array();
        var map = this._charMap;

        // Ignor symbols (-1)
        for (var i = 161; i <= 191; i++) { map[i] = -1; }
        map[215] = -1;  // ×
        map[247] = -1;  // ÷
        map[8470] = -1; // №

        var add = this.addRange;

        // ══════════════ Latin (ASCII 97-122) ══════════════
        
        // 'a' (97) - ÀÁÂÃÄÅÆ àáâãäåæ Ąą Ăă Ââ
        add([192,193,194,195,196,197,198, 224,225,226,227,228,229,230, 260,261, 258,259], 97);
        // 'c' (99) - Çç Ćć Čč
        add([199,231, 262,263, 268,269], 99);
        // 'd' (100) - Ðð Ďď
        add([208,240, 270,271], 100);
        // 'e' (101) - ÈÉÊË èéêë Ęę Ěě
        add([200,201,202,203, 232,233,234,235, 280,281, 282,283], 101);
        // 'g' (103) - Ğğ
        add([286,287], 103);
        // 'i' (105) - ÌÍÎÏ ìíîï İı Īī
        add([204,205,206,207, 236,237,238,239, 304,305, 302,303], 105);
        // 'l' (108) - Łł Ĺĺ Ľľ
        add([321,322, 313,314, 317,318], 108);
        // 'n' (110) - Ññ Ńń Ňň
        add([209,241, 323,324, 327,328], 110);
        // 'o' (111) - ÒÓÔÕÖØ òóôõöø Őő
        add([210,211,212,213,214,216, 242,243,244,245,246,248, 336,337], 111);
        // 'r' (114) - Řř Ŕŕ
        add([344,345, 340,341], 114);
        // 's' (115) - ß Śś Šš Şş
        add([223, 346,347, 352,353, 350,351], 115);
        // 't' (116) - Þþ Ťť Ţţ
        add([222,254, 356,357, 354,355], 116);
        // 'u' (117) - ÙÚÛÜ ùúûü Ůů Űű Ūū
        add([217,218,219,220, 249,250,251,252, 366,367, 368,369, 362,363], 117);
        // 'y' (121) - Ýýÿ
        add([221,253,255], 121);
        // 'z' (122) - Źź Żż Žž
        add([377,378, 379,380, 381,382], 122);

        // ══════════════ Cyrillic ══════════════

        // 'г' (1075) - Ґґ
        add([1168,1169], 1075);
        // 'е' (1077) - Ёё Єє
        add([1025,1105, 1028,1108], 1077);
        // 'и' (1080) - Іі Її
        add([1030,1110, 1031,1111], 1080);
        // 'й' (1081) - Јј
        add([1032,1112], 1081);
        // 'с' (1089) - Ѕѕ
        add([1029,1109], 1089);
        // 'у' (1091) - Ўў
        add([1038,1118], 1091);
    }

    static function normalizeChar(code)
    {
        if (skyui.filter.NameFilter._charMap == undefined) skyui.filter.NameFilter.initCharMap();
        var val = skyui.filter.NameFilter._charMap[code];
        return (val != undefined) ? val : code;
    }
    
    function isMatch(a_entry)
    {
        var entryText = a_entry[this.nameAttribute];
        var filterText = this._filterText;
        
        if(entryText == undefined || filterText == undefined) return false;
        
        entryText = entryText.toLowerCase();
        filterText = filterText.toLowerCase();
        
        var eLen = entryText.length;
        var fLen = filterText.length;
        
        var eIdx = 0;
        var fIdx = 0;
        var matched = false;

        if (skyui.filter.NameFilter._charMap == undefined) skyui.filter.NameFilter.initCharMap();
        var map = skyui.filter.NameFilter._charMap; 
        
        var ec;
        var fc;
        var mapped;

        while(eIdx < eLen)
        {
            ec = entryText.charCodeAt(eIdx);
            mapped = map[ec];
            if (mapped != undefined) ec = mapped;

            if (fIdx < fLen) {
                fc = filterText.charCodeAt(fIdx);
                mapped = map[fc];
                if (mapped != undefined) fc = mapped;
            } else {
                fc = 0; 
            }
            
            if(ec == -1) {
                eIdx++;
                continue;
            }
            
            if(fIdx < fLen && fc == -1) {
                fIdx++;
                if(fIdx >= fLen) return true;
                continue; 
            }
            
            if (fIdx < fLen && ec == fc) {
                if(!matched) matched = true;
                fIdx++;
                if(fIdx >= fLen) return true;
                eIdx++;
            } 
            else {
                if(matched) {
                    matched = false;
                    fIdx = 0;
                } else {
                    eIdx++;
                }
            }
        }
        return false;
    }
}