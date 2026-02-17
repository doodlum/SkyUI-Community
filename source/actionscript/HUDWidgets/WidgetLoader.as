class WidgetLoader extends MovieClip
{
	/* CONSTANTS */

	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = WidgetLoader.SKYUI_VERSION_MAJOR + "." + WidgetLoader.SKYUI_VERSION_MINOR + " SE";

	/* PRIVATE VARIABLES */

	private var _rootPath = "";

	private var _widgetContainer;

	private var _mcLoader;

	private var _hudMetrics;

	private var _hudModeDispatcher;


	/* INITIALIZATION */

	public function WidgetLoader()
	{
		super();
		this._mcLoader = new MovieClipLoader();
		this._mcLoader.addListener(this);
		skyui.util.GlobalFunctions.addArrayFunctions();
	}


	/* PUBLIC FUNCTIONS */

	public function onLoad()
	{
		var hudMinXY = {x:Stage.safeRect.x, y:Stage.safeRect.y};
		var hudMaxXY = {x:Stage.visibleRect.width - Stage.safeRect.x, y:Stage.visibleRect.height - Stage.safeRect.y};
		_root.globalToLocal(hudMinXY);
		_root.globalToLocal(hudMaxXY);
		this._hudMetrics = {hMin:hudMinXY.x, hMax:hudMaxXY.x, vMin:hudMinXY.y, vMax:hudMaxXY.y};

		// Dispatch event with initial hudMode
		var currentHudMode = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
		skse.SendModEvent("SKIWF_hudModeChanged", currentHudMode);

		// Create dummy movieclip which dispatches events when hudMode is changed
		this._hudModeDispatcher = new MovieClip();
		this._hudModeDispatcher.onModeChange = function(a_hudMode)
		{
			skse.SendModEvent("SKIWF_hudModeChanged", a_hudMode);
		};
		_root.HUDMovieBaseInstance.HudElements.push(this._hudModeDispatcher);

		// Fixes for elements which become visible for large resolutions
		_root.HUDMovieBaseInstance.WeightTranslated._alpha = 0;
		_root.HUDMovieBaseInstance.ValueTranslated._alpha = 0;
		_root.HUDMovieBaseInstance.QuestUpdateBaseInstance.LevelUpTextInstance._alpha = 0;
	}

	public function onLoadInit(a_widgetHolder)
	{
		if (a_widgetHolder.widget == undefined)
		{
			// Widgets need to have main MovieClip on the root with an instance name of "widget"
			skse.SendModEvent("SKIWF_widgetError", "WidgetInitFailure", Number(a_widgetHolder._name));
			return;
		}
		a_widgetHolder.onModeChange = function(a_hudMode)
		{
			var widgetHolder = this;
			if (widgetHolder.widget.onModeChange != undefined)
			{
				widgetHolder.widget.onModeChange(a_hudMode);
			}
		};
		a_widgetHolder.widget.setHudMetrics(this._hudMetrics);
		a_widgetHolder.widget.setRootPath(this._rootPath);
		skse.SendModEvent("SKIWF_widgetLoaded", a_widgetHolder._name);
	}

	public function onLoadError(a_widgetHolder, a_errorCode)
	{
		skse.SendModEvent("SKIWF_widgetError", "WidgetLoadFailure", Number(a_widgetHolder._name));
	}

	public function setRootPath(a_path)
	{
		skse.Log("WidgetLoader.as: setRootPath(a_path = " + a_path + ")");
		this._rootPath = a_path;
	}

	public function loadWidgets(/* widgetSources (128) */)
	{
		var widget;
		var index;
		if (this._widgetContainer != undefined)
		{
			for (var s in this._widgetContainer)
			{
				widget = this._widgetContainer[s];
				if (widget != null && widget instanceof MovieClip)
				{
					this._mcLoader.unloadClip(widget);
					index = _root.HUDMovieBaseInstance.HudElements.indexOf(widget);
					if (index != undefined)
					{
						_root.HUDMovieBaseInstance.HudElements.splice(index, 1);
					}
				}
			}
		}
		var i = 0;
		while (i < arguments.length)
		{
			if (arguments[i] != undefined && arguments[i] != "")
			{
				this.loadWidget(String(i), arguments[i]);
			}
			i = i + 1;
		}
	}

	public function loadWidget(a_widgetID, a_widgetSource)
	{
		skse.Log("WidgetLoader.as: loadWidget(a_widgetID = " + a_widgetID + ", a_widgetSource = " + a_widgetSource + ")");
		if (this._widgetContainer == undefined)
		{
			this.createWidgetContainer();
		}
		var widgetHolder = this._widgetContainer.createEmptyMovieClip(a_widgetID, this._widgetContainer.getNextHighestDepth());
		this._mcLoader.loadClip(this._rootPath + "widgets/" + a_widgetSource, widgetHolder);
	}


	/* PRIVATE FUNCTIONS */

	private function createWidgetContainer()
	{
		// -16384 places the WidgetContainer beneath all elements which were added to the stage in Flash.
		this._widgetContainer = _root.createEmptyMovieClip("WidgetContainer", -16384);
		// Locks _widgetContainer to the safe top left of the Stage
		this._widgetContainer.Lock("TL");
	}
}
