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
        if(a_filterText == undefined)
        {
            a_filterText = "";
        }
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
        
        var i = 0;
        while(i < a_filteredList.length)
        {
            if(!this.isMatch(a_filteredList[i]))
            {
                a_filteredList.splice(i, 1);
                i -= 1;
            }
            i += 1;
        }
    }
    
    /**
     * Normalizes Unicode characters to their base ASCII equivalents for case-insensitive,
     * accent-insensitive searching. Returns -1 for characters that should be ignored.
     * 
     * This handles:
     * - Cyrillic yo/yu/yi variants → base Cyrillic letters
     * - Latin extended characters (A-Z with diacritics) → base a-z
     * - Special symbols → -1 (ignored)
     */
    static function normalizeChar(code)
    {
        // ═══════════════════════════════════════════════════════════════════
        // CYRILLIC CHARACTER NORMALIZATION
        // ═══════════════════════════════════════════════════════════════════
        
        // Ё (U+0401) and ё (U+0451) → е (U+0435) [Yo → Ye]
        if(code == 1025 || code == 1105)
        {
            return 1077;
        }
        
        switch(code)
        {
            // Є (U+0404) and є (U+0454) → е (U+0435) [Ukrainian Ye → Ye]
            case 1028:
            case 1108:
                return 1077;
                
            // І (U+0406) and і (U+0456) → и (U+0438) [Ukrainian I → I]
            case 1030:
            case 1110:
                return 1080;
                
            // Ї (U+0407) and ї (U+0457) → и (U+0438) [Ukrainian Yi → I]
            case 1031:
            case 1111:
                return 1080;
        }
        
        // Ў (U+040E) and ў (U+045E) → у (U+0443) [Belarusian Short U → U]
        if(code == 1038 || code == 1118)
        {
            return 1091;
        }
        
        switch(code)
        {
            // Ј (U+0408) and ј (U+0458) → й (U+0439) [Serbian Je → Short I]
            case 1032:
            case 1112:
                return 1081;
                
            // Ґ (U+0490) and ґ (U+0491) → г (U+0433) [Ukrainian Ghe → Ghe]
            case 1168:
            case 1169:
                return 1075;
                
            // Ѕ (U+0405) and ѕ (U+0455) → с (U+0441) [Dze → Es]
            case 1029:
            case 1109:
                return 1081;
        }
        
        // ═══════════════════════════════════════════════════════════════════
        // LATIN EXTENDED-A & B (U+00C0-U+00FF) - Latin-1 Supplement
        // ═══════════════════════════════════════════════════════════════════
        
        if(code >= 192 && code <= 255)
        {
            switch(code)
            {
                // A variants: À Á Â Ã Ä Å Æ à á â ã ä å æ → a
                case 192: case 193: case 194: case 195: case 196: case 197: case 198:
                case 224: case 225: case 226: case 227: case 228: case 229: case 230:
                    return 97;  // 'a'
                    
                // C variants: Ç ç → c
                case 199: case 231:
                    return 99;  // 'c'
                    
                // E variants: È É Ê Ë è é ê ë → e
                case 200: case 201: case 202: case 203:
                case 232: case 233: case 234: case 235:
                    return 101; // 'e'
                    
                // I variants: Ì Í Î Ï ì í î ï → i
                case 204: case 205: case 206: case 207:
                case 236: case 237: case 238: case 239:
                    return 105; // 'i'
                    
                // D/ETH variants: Ð ð → d (Eth)
                case 208: case 240:
                    return 100; // 'd'
                    
                // N variants: Ñ ñ → n
                case 209: case 241:
                    return 110; // 'n'
                    
                // O variants: Ò Ó Ô Õ Ö Ø ò ó ô õ ö ø → o
                case 210: case 211: case 212: case 213: case 214: case 216:
                case 242: case 243: case 244: case 245: case 246: case 248:
                    return 111; // 'o'
                    
                // Multiplication/Division: × ÷ → -1 (ignored)
                case 215: case 247:
                    return -1;
                    
                // U variants: Ù Ú Û Ü ù ú û ü → u
                case 217: case 218: case 219: case 220:
                case 249: case 250: case 251: case 252:
                    return 117; // 'u'
                    
                // Y variants: Ý ý ÿ → y
                case 221: case 253: case 255:
                    return 121; // 'y'
                    
                // Thorn: Þ þ → t
                case 222: case 254:
                    return 116; // 't'
                    
                // Sharp S: ß → s
                case 223:
                    return 115; // 's'
            }
        }
        
        // ═══════════════════════════════════════════════════════════════════
        // LATIN EXTENDED (U+0100-U+017E) - Central European, Baltic, etc.
        // ═══════════════════════════════════════════════════════════════════
        
        if(code >= 256 && code <= 382)
        {
            switch(code)
            {
                // Ą ą (Polish A-ogonek) → a
                case 260: case 261:
                    return 97;
                    
                // Ć ć (Polish C-acute) → c
                case 262: case 263:
                    return 99;
                    
                // Ę ę (Polish E-ogonek) → e
                case 280: case 281:
                    return 101;
                    
                // Ł ł (Polish L-stroke) → l
                case 321: case 322:
                    return 108;
                    
                // Ń ń (Polish N-acute) → n
                case 323: case 324:
                    return 110;
                    
                // Ś ś (Polish S-acute) → s
                case 346: case 347:
                    return 115;
                    
                // Ź ź (Polish Z-acute) → z
                case 377: case 378:
                    return 122;
                    
                // Ż ż (Polish Z-dot) → z
                case 379: case 380:
                    return 122;
                    
                // Č č (Czech/Croatian C-caron) → c
                case 268: case 269:
                    return 99;
                    
                // Ď ď (Czech D-caron) → d
                case 270: case 271:
                    return 100;
                    
                // Ě ě (Czech E-caron) → e
                case 282: case 283:
                    return 101;
                    
                // Ň ň (Czech N-caron) → n
                case 327: case 328:
                    return 110;
                    
                // Ř ř (Czech R-caron) → r
                case 344: case 345:
                    return 114;
                    
                // Š š (Czech/Slovak S-caron) → s
                case 352: case 353:
                    return 115;
                    
                // Ť ť (Czech T-caron) → t
                case 356: case 357:
                    return 116;
                    
                // Ů ů (Czech U-ring) → u
                case 366: case 367:
                    return 117;
                    
                // Ž ž (Czech Z-caron) → z
                case 381: case 382:
                    return 122;
                    
                // Ă ă (Romanian A-breve) → a
                case 258: case 259:
                    return 97;
                    
                // Â â (Romanian/Circumflex A) → a
                case 194: case 226:
                    return 97;
                    
                // Î î (Romanian I-circumflex) → i
                case 206: case 238:
                    return 105;
                    
                // Ő ő (Hungarian O-double acute) → o
                case 336: case 337:
                    return 111;
                    
                // Ű ű (Hungarian U-double acute) → u
                case 368: case 369:
                    return 117;
                    
                // Ğ ğ (Turkish G-breve) → g
                case 286: case 287:
                    return 103;
                    
                // İ ı (Turkish dotted/dotless I) → i
                case 304: case 305:
                    return 105;
                    
                // Ş ş (Turkish S-cedilla) → s
                case 350: case 351:
                    return 115;
                    
                // Ĺ ĺ (L-acute) → l
                case 313: case 314:
                    return 108;
                    
                // Ľ ľ (L-caron) → l
                case 317: case 318:
                    return 108;
                    
                // Ŕ ŕ (R-acute) → r
                case 340: case 341:
                    return 114;
                    
                // Ţ ţ (T-cedilla) → t
                case 354: case 355:
                    return 116;
                    
                // Ī ī (I-macron) → i
                case 302: case 303:
                    return 105;
                    
                // Ū ū (U-macron) → u
                case 362: case 363:
                    return 117;
            }
        }
        
        // ═══════════════════════════════════════════════════════════════════
        // SPECIAL SYMBOLS TO IGNORE
        // ═══════════════════════════════════════════════════════════════════
        
        // Inverted punctuation (¡ ¿) and № (numero sign) → -1 (ignored)
        if(code >= 161 && code <= 191 || code == 8470)
        {
            return -1;
        }
        
        // Return unchanged for all other characters (including standard ASCII)
        return code;
    }
    
    /**
     * Checks if an entry matches the current filter text.
     * Performs fuzzy matching that allows skipping non-matching characters.
     * Example: "hw" matches "Hello World" (H...W...)
     */
    function isMatch(a_entry)
    {
        var entryText = a_entry[this.nameAttribute];
        var filterText = this._filterText;
        
        if(entryText == undefined || filterText == undefined)
        {
            return false;
        }
        
        entryText = entryText.toLowerCase();
        filterText = filterText.toLowerCase();
        
        var entryIndex = 0;
        var filterIndex = 0;
        var hasMatched = false;
        var entryChar;
        var filterChar;
        
        while(entryIndex < entryText.length)
        {
            entryChar = skyui.filter.NameFilter.normalizeChar(entryText.charCodeAt(entryIndex));
            filterChar = skyui.filter.NameFilter.normalizeChar(filterText.charCodeAt(filterIndex));
            
            if(entryChar == -1)
            {
                entryIndex += 1;
            }
            else if(filterChar == -1)
            {
                filterIndex += 1;
                if(filterIndex >= filterText.length)
                {
                    return true;
                }
            }
            else
            {
                if(entryChar == filterChar)
                {
                    if(!hasMatched)
                    {
                        hasMatched = true;
                    }
                    filterIndex += 1;
                    if(filterIndex >= filterText.length)
                    {
                        return true;
                    }
                }
                else if(hasMatched)
                {
                    hasMatched = false;
                    filterIndex = 0;
                }
                entryIndex += 1;
            }
        }
        
        return false;
    }
}
