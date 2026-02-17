class Map.LocalMap extends MovieClip
{
	/* CONSTANTS */

	private static var STATE_HIDDEN = 0;
	private static var STATE_LOCALMAP = 1;
	private static var STATE_FINDLOCATION = 2;


	/* PRIVATE VARIABLES */

	private var _mapImageLoader;

	private var _bUpdated = false;

	private var _bottomBar;

	// The local map has to manage visiblity of the location finder as well.
	private var _locationFinder;

	private var _bShow = false;

	private var _state = Map.LocalMap.STATE_HIDDEN;

	private var _bRequestFindLoc = false;


	/* STAGE ELEMENTS */

	public var LocalMapHolder_mc;
	public var LocationTextClip;
	public var ClearedText;


	/* PROPERTIES */

	// @API
	public var IconDisplay;

	public var TextureHolder;
	public var LocationDescription;
	public var ClearedDescription;

	private var _textureWidth = 800;

	public function get TextureWidth()
	{
		return this._textureWidth;
	}

	private var _textureHeight = 450;

	public function get TextureHeight()
	{
		return this._textureHeight;
	}


	/* INITIALIZATION */

	public function LocalMap()
	{
		super();
		this.IconDisplay = new Map.MapMenu(this);

		this._mapImageLoader = new MovieClipLoader();
		this._mapImageLoader.addListener(this);

		this.LocationDescription = this.LocationTextClip.LocationText;
		this.LocationDescription.noTranslate = true;

		this.LocationTextClip.swapDepths(3);

		this.ClearedDescription = this.ClearedText;
		this.ClearedDescription.noTranslate = true;

		this.TextureHolder = this.LocalMapHolder_mc;
	}


	/* PUBLIC FUNCTIONS */

	// @API
	public function InitMap()
	{
		if(!this._bUpdated)
		{
			this._mapImageLoader.loadClip("img://Local_Map",this.TextureHolder);
			this._bUpdated = true;
		}

		this.updateLocalMapExtends(true);
	}

	// @API
	public function Show(a_bShow)
	{
		this._bShow = a_bShow;

		if(a_bShow)
		{
			if(this._bRequestFindLoc)
			{
				this.setState(Map.LocalMap.STATE_FINDLOCATION);
			}
			else
			{
				this.setState(Map.LocalMap.STATE_LOCALMAP);
			}
		}
		else
		{
			this.setState(Map.LocalMap.STATE_HIDDEN);
		}

		this._bRequestFindLoc = false;
	}

	// @API
	public function SetTitle(a_name, a_cleared)
	{
		this.LocationDescription.text = a_name != undefined ? a_name : "";
		this.ClearedDescription.text = a_cleared != undefined ? "(" + a_cleared + ")" : "";
	}

	public function showLocationFinder()
	{
		// Local map mode
		if(this._state == Map.LocalMap.STATE_LOCALMAP)
		{
			this.setState(Map.LocalMap.STATE_FINDLOCATION);
		}
		// World map mode - delay state update for Show()
		else if(this._state == Map.LocalMap.STATE_HIDDEN)
		{
			this._bRequestFindLoc = true;
			gfx.io.GameDelegate.call("ToggleMapCallback",[]);
		}
		// Ignore if state == STATE_FINDLOCATION already
	}

	public function setBottomBar(a_bottomBar)
	{
		this._bottomBar = a_bottomBar;
	}

	public function setLocationFinder(a_locationFinder)
	{
		this._locationFinder = a_locationFinder;
	}


	/* PRIVATE FUNCTIONS */

	private function onLoadInit(a_targetClip)
	{
		a_targetClip._width = this._textureWidth;
		a_targetClip._height = this._textureHeight;
	}

	private function setState(a_newState)
	{
		var oldState = this._state;
		var buttonPanel = this._bottomBar.buttonPanel;

		if(a_newState == Map.LocalMap.STATE_LOCALMAP)
		{
			this.updateLocalMapExtends(true);
			this._parent.gotoAndPlay("fadeIn");
			this._parent._visible = true;

			buttonPanel.button0.label = "$World Map";
			buttonPanel.button2.visible = true;
			buttonPanel.button3.visible = true;
			if(!buttonPanel.button4.disabled)
			{
				buttonPanel.button4.visible = true;
			}
			buttonPanel.button5.visible = false;
			buttonPanel.button6.visible = false;
		}
		else if(a_newState == Map.LocalMap.STATE_FINDLOCATION)
		{
			this.updateLocalMapExtends(false);

			if(oldState == Map.LocalMap.STATE_LOCALMAP)
			{
				this._parent.gotoAndPlay("fadeOut");
				this._parent._visible = true;
			}
			else
			{
				this._parent._visible = false;
			}

			this._locationFinder.show();

			buttonPanel.button0.label = "$World Map";
			buttonPanel.button2.visible = false;
			buttonPanel.button3.visible = false;
			buttonPanel.button4.visible = false;
			buttonPanel.button5.visible = false;
			buttonPanel.button6.visible = true;
		}
		else if(a_newState == Map.LocalMap.STATE_HIDDEN)
		{
			if(oldState == Map.LocalMap.STATE_LOCALMAP)
			{
				this._parent.gotoAndPlay("fadeOut");
			}
			else if(oldState == Map.LocalMap.STATE_FINDLOCATION)
			{
				this._locationFinder.hide();
			}
			this._parent._visible = true;

			buttonPanel.button0.label = "$Local Map";
			buttonPanel.button2.visible = true;
			buttonPanel.button3.visible = true;
			if(!buttonPanel.button4.disabled)
			{
				buttonPanel.button4.visible = true;
			}
			buttonPanel.button5.visible = true;
			buttonPanel.button6.visible = false;
		}

		buttonPanel.updateButtons(true); // Label length changed

		this._state = a_newState;
	}

	private function updateLocalMapExtends(a_bEnabled)
	{
		if(a_bEnabled)
		{
			var textureTopLeft = {x:this._x, y:this._y};
			var textureBottomRight = {x:this._x + this._textureWidth, y:this._y + this._textureHeight};
			this._parent.localToGlobal(textureTopLeft);
			this._parent.localToGlobal(textureBottomRight);

			gfx.io.GameDelegate.call("SetLocalMapExtents",[textureTopLeft.x,textureTopLeft.y,textureBottomRight.x,textureBottomRight.y]);
		}
		else
		{
			gfx.io.GameDelegate.call("SetLocalMapExtents",[0,0,0,0]);
		}
	}
}
