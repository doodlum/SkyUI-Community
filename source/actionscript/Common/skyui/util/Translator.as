class skyui.util.Translator
{
  /* PRIVATE VARIABLES */

	private static var _translator: TextField;

	// "$KEY" -> translated text. Translating goes through a hidden TextField (assign text, read it back), which
	// is a text-layout round trip; item data setters call it several times per entry with a handful of distinct
	// keys, so with thousands of items it added up. Translations don't change while a menu is open.
	private static var _cache: Object;


  /* PUBLIC FUNCTIONS */

  	// Translate simple strings
	public static function translate(a_str: String)
	{
		if (a_str == "")
			return "";

		if (a_str.charAt(0) != "$")
			return a_str;

		if (skyui.util.Translator._cache == undefined)
			skyui.util.Translator._cache = {};

		var cached = skyui.util.Translator._cache[a_str];
		if (cached != undefined)
			return cached;

		if (skyui.util.Translator._translator == undefined) {
			skyui.util.Translator._translator = _root.createTextField("_translator", _root.getNextHighestDepth(), 0, 0, 1, 1);
			skyui.util.Translator._translator._visible = false;
		}

		skyui.util.Translator._translator.text = a_str;

		var result = skyui.util.Translator._translator.text;
		skyui.util.Translator._cache[a_str] = result;
		return result;
	}

	// Translate with support for substrings, i.e. "$My text, default value {$Default value}"
	public static function translateNested(a_str: String)
	{
		if (a_str == "")
			return "";

		// Quick test to decide if we can skip
		if (a_str.indexOf("{") == -1)
			return skyui.util.Translator.translate(a_str);

		// Collect substrings
		var subStrings: Array = [];
		var offset = 0;

		do {
			var startIndex = a_str.indexOf("{", offset);
			var endIndex = a_str.indexOf("}", offset);

			if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
				var s = a_str.slice(startIndex + 1, endIndex);
				subStrings.push(skyui.util.Translator.translate(s));

				a_str = a_str.slice(0, startIndex + 1) + a_str.slice(endIndex);

				offset = startIndex + 2;
			} else {
				break;
			}

		} while (true);

		// Translate the base string
		a_str = skyui.util.Translator.translate(a_str);

		// Split at {} and interleave with the substrings
		var t = a_str.split("{}");
		var result = "";

		var i;
		for (i = 0; i < subStrings.length; i++)
			result += t[i] + subStrings[i];

		if (i < (t.length))
			result += t[i];

		return result;
	}
}
