class MenuDialog extends OptionDialog
{
	/* PRIVATE VARIABLES */

	private var _defaultControls;
	private var _closeControls;


	/* STAGE ELEMENTS */

	public var menuList;


	/* PROPERTIES */

	public var menuOptions;
	public var menuStartIndex;
	public var menuDefaultIndex;


	/* INITIALIZATION */

	public function MenuDialog()
	{
		super();
	}


	/* PUBLIC FUNCTIONS */

	// @override OptionDialog
	public function initButtons()
	{
		if(this.platform == 0)
		{
			this._defaultControls = skyui.defines.Input.ReadyWeapon;
			this._closeControls = skyui.defines.Input.Tab;
		}
		else
		{
			this._defaultControls = skyui.defines.Input.YButton;
			this._closeControls = skyui.defines.Input.Cancel;
		}

		this.leftButtonPanel.clearButtons();
		var defaultButton = leftButtonPanel.addButton({text: "$Default", controls: _defaultControls});
		defaultButton.addEventListener("press",this,"onDefaultPress");
		this.leftButtonPanel.updateButtons();

		this.rightButtonPanel.clearButtons();
		var closeButton = rightButtonPanel.addButton({text: "$Exit", controls: _closeControls});
		closeButton.addEventListener("press",this,"onExitPress");
		this.rightButtonPanel.updateButtons();
	}

	// @override OptionDialog
	public function initContent()
	{
		this.menuList.addEventListener("itemPress",this,"onMenuListPress");
		this.menuList.listEnumeration = new skyui.components.list.BasicEnumeration(this.menuList.entryList);

		var i = 0;
		var entry;
		while(i < this.menuOptions.length)
		{
			var entry = {text: menuOptions[i], align: "center", enabled: true, state: "normal"};
			this.menuList.entryList.push(entry);
			i = i + 1;
		}

		var e = this.menuList.entryList[this.menuStartIndex];
		this.menuList.listState.activeEntry = e;
		this.menuList.selectedIndex = this.menuStartIndex;
		this.menuList.InvalidateData();
		gfx.managers.FocusHandler.instance.setFocus(this.menuList,0);
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		var nextClip = pathToFocus.shift();
		if(nextClip.handleInput(details,pathToFocus))
		{
			return true;
		}

		if(Shared.GlobalFunc.IsKeyPressed(details,false))
		{
			if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
			{
				this.onExitPress();
				return true;
			}
			if(details.control == this._defaultControls.name)
			{
				this.onDefaultPress();
				return true;
			}
		}

		// Don't forward to higher level
		return true;
	}


	/* PRIVATE FUNCTIONS */

	private function onMenuListPress(a_event)
	{
		var e = a_event.entry;
		if(e == undefined)
		{
			return undefined;
		}
		this.menuList.listState.activeEntry = e;
		this.menuList.UpdateList();
	}

	private function onDefaultPress()
	{
		this.setActiveMenuIndex(this.menuDefaultIndex);
		this.menuList.selectedIndex = this.menuDefaultIndex;
	}

	private function onExitPress()
	{
		skse.SendModEvent("SKICP_menuAccepted",null,this.getActiveMenuIndex());
		skyui.util.DialogManager.close();
	}

	private function setActiveMenuIndex(a_index)
	{
		var e = this.menuList.entryList[a_index];
		this.menuList.listState.activeEntry = e;
		this.menuList.UpdateList();
	}

	private function getActiveMenuIndex()
	{
		var index = this.menuList.listState.activeEntry.itemIndex;
		return index == undefined ? -1 : index;
	}
}
