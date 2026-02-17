class StatsPage extends MovieClip
{
	/* STAGE ELEMENTS */

	var CategoryList;
	var CategoryList_mc;
	var StatsList_mc;

	/* PRIVATE VARIABLES */

	var _StatsList;
	var bUpdated;

	/* CONSTRUCTOR */

	public function StatsPage()
	{
		super();
		CategoryList = CategoryList_mc.List_mc;
		_StatsList = StatsList_mc;
		bUpdated = false;
	}

	/* PUBLIC FUNCTIONS */

	public function onLoad()
	{
		CategoryList.entryList.push({text: "$GENERAL", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$QUEST", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$COMBAT", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$MAGIC", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$CRAFTING", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$CRIME", stats: new Array(), savedHighlight: 0});
		CategoryList.InvalidateData();
		CategoryList.addEventListener("listMovedUp", this, "onCategoryListMoveUp");
		CategoryList.addEventListener("listMovedDown", this, "onCategoryListMoveDown");
		CategoryList.addEventListener("selectionChange", this, "onCategoryListMouseSelectionChange");
		CategoryList.disableInput = true;
		_StatsList.disableSelection = true;
	}

	public function startPage()
	{
		CategoryList.disableInput = false;
		gfx.managers.FocusHandler.instance.setFocus(CategoryList, 0);
		if (bUpdated) {
			return undefined;
		}
		gfx.io.GameDelegate.call("updateStats", [], this, "PopulateStatsList");
		bUpdated = true;
	}

	public function endPage()
	{
		CategoryList.disableInput = true;
	}

	public function PopulateStatsList()
	{
		var STAT_TEXT = 0;
		var STAT_VALUE = 1;
		var STAT_ENTRYLISTINDEX = 2;
		var STAT_UNKNOWN = 3;
		var STAT_STRIDE = 4;

		var i = 0;
		var stat;
		while (i < arguments.length) {
			stat = {text: "$" + arguments[i + STAT_TEXT], value: arguments[i + STAT_VALUE]};
			CategoryList.entryList[arguments[i + STAT_ENTRYLISTINDEX]].stats.push(stat);
			i += STAT_STRIDE;
		}
		onCategoryHighlight();
	}

	public function onRightStickInput(afX, afY)
	{
		if (afY < 0) {
			_StatsList.moveSelectionDown();
			return undefined;
		}
		_StatsList.moveSelectionUp();
	}

	public function SetPlatform(aiPlatform, abPS3Switch)
	{
		CategoryList.SetPlatform(aiPlatform, abPS3Switch);
		_StatsList.SetPlatform(aiPlatform, abPS3Switch);
	}

	/* PRIVATE FUNCTIONS */

	private function onCategoryHighlight()
	{
		var stats = CategoryList.selectedEntry.stats;
		_StatsList.ClearList();
		_StatsList.scrollPosition = 0;
		var i = 0;
		while (i < stats.length) {
			_StatsList.entryList.push(stats[i]);
			i = i + 1;
		}
		_StatsList.InvalidateData();
	}

	private function onCategoryListMoveUp(event)
	{
		onCategoryHighlight();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			CategoryList._parent.gotoAndPlay("moveUp");
		}
	}

	private function onCategoryListMoveDown(event)
	{
		onCategoryHighlight();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			CategoryList._parent.gotoAndPlay("moveDown");
		}
	}

	private function onCategoryListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0 && event.index != -1) {
			onCategoryHighlight();
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}
}
