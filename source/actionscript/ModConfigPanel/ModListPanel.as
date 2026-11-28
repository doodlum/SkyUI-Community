class ModListPanel extends MovieClip
{
  /* CONSTANTS */
    
    private var INIT = 0;
    private var LIST_ACTIVE = 1;
    private var SUBLIST_ACTIVE = 2;
    private var TRANSITION_TO_SUBLIST = 3;
    private var TRANSITION_TO_LIST = 4;
    
    private var ANIM_LIST_FADE_OUT = 0;
    private var ANIM_LIST_FADE_IN = 1;
    private var ANIM_SUBLIST_FADE_OUT = 2;
    private var ANIM_SUBLIST_FADE_IN = 3;
    private var ANIM_DECORTITLE_FADE_OUT = 4;
    private var ANIM_DECORTITLE_FADE_IN = 5;
    private var ANIM_DECORTITLE_TWEEN = 6;
    
    
  /* PRIVATE VARIABLES */
    
    private var _state: Number = ModListPanel.prototype.INIT;

    private var _titleText : String;
    
    private var _modList: ScrollingList;
    private var _subList: ScrollingList;
    
    private var _bDisabled: Boolean = false;


  /* STAGE ELEMENTS */
    
    public var decorTop: MovieClip;
    public var decorTitle: MovieClip;
    public var decorBottom: MovieClip;
    
    public var modListFader: MovieClip;
    public var subListFader: MovieClip;
    
    public var sublistIndicator: MovieClip;
    
    
  /* INITIALIZATION */

    public function ModListPanel()
    {
        super();
        this._modList = this.modListFader.list;
        this._subList = this.subListFader.list;
        
        gfx.events.EventDispatcher.initialize(this);
    }
    
    // @override MovieClip
    private function onLoad()
    {
        // Init state
        this.hideDecorTitle(true);
        this.modListFader.gotoAndStop("show");
        this.subListFader.gotoAndStop("hide");
        this.sublistIndicator._visible = false;
        
        this._state = this.LIST_ACTIVE;
        
        this._subList.addEventListener("itemPress", this, "onSubListPress");
    }
    
    
  /* PROPERTIES */
    
    public function get selectedEntry()
    {
        if (this._state == this.LIST_ACTIVE)
            return this._modList.selectedEntry;
        else if (this._state == this.SUBLIST_ACTIVE)
            return this._subList.selectedEntry;
        else
            return null;
    }
    
    public function get isDisabled()
    {
        return this._bDisabled;
    }
    
    public function set isDisabled(a_bDisabled: Boolean)
    {
        this._bDisabled = a_bDisabled;
        this._subList.disableSelection = this._subList.disableInput = a_bDisabled;
        this._modList.disableSelection = this._modList.disableInput = a_bDisabled;
    }
    

  /* PUBLIC FUNCTIONS */

    // @mixin by gfx.events.EventDispatcher
    public var dispatchEvent: Function;
    public var dispatchQueue: Function;
    public var hasEventListener: Function;
    public var addEventListener: Function;
    public var removeEventListener: Function;
    public var removeAllEventListeners: Function;
    public var cleanUpEvents: Function;
    
    public function isSublistActive()
    {
        return (this._state == this.SUBLIST_ACTIVE);
    }

    public function isListActive()
    {
        return (this._state == this.LIST_ACTIVE);
    }

    public function showList()
    {
       this.setState(this.TRANSITION_TO_LIST);
    }
    
    public function showSublist()
    {
        if (this._modList.selectedClip == null || this._modList.selectedEntry == null)
            return;

        this.setState(this.TRANSITION_TO_SUBLIST);
    }
    
    // @GFx
    public function handleInput(details: InputDetails, pathToFocus: Array)
    {
        var nextClip = pathToFocus.shift();
        if (nextClip && nextClip.handleInput(details, pathToFocus))
            return true;
            
        if (this._bDisabled)
            return false;
        
        if (this._state == this.LIST_ACTIVE) {
            if (this._modList.handleInput(details, pathToFocus))
                return true;
        } else if (this._state == this.SUBLIST_ACTIVE) {
            
            if (Shared.GlobalFunc.IsKeyPressed(details, false)) {
                if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
                    this.showList();
                    return true;
                }
            }
            
            if (this._subList.handleInput(details, pathToFocus))
                return true;
        }
        
        return false;
    }


  /* PRIVATE FUNCTIONS */

    private function setState(a_state: Number)
    {
        switch (a_state) {
            case this.LIST_ACTIVE:
                this.modListFader.gotoAndStop("show");
                this._modList.disableInput = false;
                this._modList.disableSelection = false;
                var restored = this._modList.listState.savedIndex;
                this._modList.selectedIndex = (restored > -1) ? restored : 0;

                if (this.modListFader.getDepth() < this.subListFader.getDepth())
                    this.modListFader.swapDepths(this.subListFader);
                    
                this.dispatchEvent({type: "modListEnter"});
                break;
                
            case this.SUBLIST_ACTIVE:
                this.subListFader.gotoAndStop("show");
                this._subList.disableInput = false;
                this._subList.disableSelection = false;
                this._subList.selectedIndex = -1;

                if (this.subListFader.getDepth() < this.modListFader.getDepth())
                    this.subListFader.swapDepths(this.modListFader);

                this.decorTitle.onPress = function()
                {
                    if (!this._parent.isDisabled)
                        this._parent.showList();
                };
                
                this.dispatchEvent({type: "subListEnter"});
                break;
                
            case this.TRANSITION_TO_SUBLIST:
                this._titleText = this._modList.selectedEntry.text;
                this.decorTitle._y = this._modList.selectedClip._y;
                this.hideDecorTitle(false);
                this.decorTitle.gotoAndPlay("fadeIn");
                this.decorTitle.textHolder.textField.text = this._titleText;
                this.modListFader.gotoAndPlay("fadeOut");

                this._modList.listState.savedIndex = this._modList.selectedIndex;
                this._modList.disableInput = true;
                this._modList.disableSelection = true;
                
                this.sublistIndicator._visible = false;
                
                this.dispatchEvent({type: "modListExit"});
                break;
                
            case this.TRANSITION_TO_LIST:
                this.decorTitle.gotoAndPlay("fadeOut");
                this.subListFader.gotoAndPlay("fadeOut");
                
                delete this.decorTitle.onPress;
                
                this._subList.disableInput = true;
                this._subList.disableSelection = true;
                
                this.dispatchEvent({type: "subListExit"});
                break;
                
            default:
                return;
        }
        
        this._state = a_state;
    }
    
    private function onAnimFinish(a_animID: Number)
    {
        switch (a_animID) {
            case this.ANIM_DECORTITLE_FADE_IN:
                // Should happen at the same time as ANIM_LIST_FADE_OUT, we just need to handle one of them.
                var tween = new mx.transitions.Tween(this.decorTitle, "_y", mx.transitions.easing.Strong.easeOut, this.decorTitle._y, this._modList._x + this._modList.topBorder, 0.75, true);
                tween.FPS = 60;
                tween.onMotionFinished = mx.utils.Delegate.create(this, this.decorMotionFinishedFunc);
                tween.onMotionChanged = mx.utils.Delegate.create(this, this.decorMotionUpdateFunc);
                break;
                
            case this.ANIM_DECORTITLE_TWEEN:
                this.subListFader.gotoAndPlay("fadeIn");
                break;
                
            case this.ANIM_SUBLIST_FADE_IN:
                this.setState(this.SUBLIST_ACTIVE);
                break;
                
            case this.ANIM_SUBLIST_FADE_OUT:
                // Should happen at the same time as ANIM_DECORTITLE_FADE_OUT, we just need to handle one of them.
                this.modListFader.gotoAndPlay("fadeIn");
                this.hideDecorTitle(true);
                break;
                    
            case this.ANIM_LIST_FADE_IN:
                this.setState(this.LIST_ACTIVE);
                break;
        }
    }
    
    private function onSubListPress(a_event: Object)
    {
    }
    
    private function decorMotionFinishedFunc()
    {
        this.onAnimFinish(this.ANIM_DECORTITLE_TWEEN);
    }
    
    private function decorMotionUpdateFunc()
    {
        this.decorTop._y = this._modList._y;
        this.decorTop._height = this.decorTitle._y - this.decorTop._y ;
        
        this.decorBottom._y = this.decorTitle._y + this.decorTitle._height;
        this.decorBottom._height = this.decorBottom._y - this._modList._height;
    }
    
    private function hideDecorTitle(a_hide: Boolean)
    {
        if (a_hide) {
            this.decorTop._visible = true;
            this.decorTop._y = this._modList._y;
            this.decorTop._height = this._modList._height;
            this.decorTitle._visible = false;
            this.decorBottom._visible = false;
        } else {
            this.decorTitle._visible = true;
            this.decorTop._visible = true;
            this.decorTop._y = this._modList._y;
            this.decorTop._height = this.decorTitle._y - this.decorTop._y;
            this.decorBottom._visible = true;
            this.decorBottom._y = this.decorTitle._y + this.decorTitle._height;
            this.decorBottom._height = this.decorBottom._y - this._modList._height;
        }
    }
}
