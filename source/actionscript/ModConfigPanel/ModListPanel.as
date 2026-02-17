class ModListPanel extends MovieClip
{
   var _modList;
   var _subList;
   var _titleText;
   var decorBottom;
   var decorTitle;
   var decorTop;
   var dispatchEvent;
   var modListFader;
   var subListFader;
   var sublistIndicator;
   var INIT = 0;
   var LIST_ACTIVE = 1;
   var SUBLIST_ACTIVE = 2;
   var TRANSITION_TO_SUBLIST = 3;
   var TRANSITION_TO_LIST = 4;
   var ANIM_LIST_FADE_OUT = 0;
   var ANIM_LIST_FADE_IN = 1;
   var ANIM_SUBLIST_FADE_OUT = 2;
   var ANIM_SUBLIST_FADE_IN = 3;
   var ANIM_DECORTITLE_FADE_OUT = 4;
   var ANIM_DECORTITLE_FADE_IN = 5;
   var ANIM_DECORTITLE_TWEEN = 6;
   var _state = ModListPanel.prototype.INIT;
   var _bDisabled = false;
   function ModListPanel()
   {
      super();
      this._modList = this.modListFader.list;
      this._subList = this.subListFader.list;
      gfx.events.EventDispatcher.initialize(this);
   }
   function onLoad()
   {
      this.hideDecorTitle(true);
      this.modListFader.gotoAndStop("show");
      this.subListFader.gotoAndStop("hide");
      this.sublistIndicator._visible = false;
      this._state = this.LIST_ACTIVE;
      this._subList.addEventListener("itemPress",this,"onSubListPress");
   }
   function get selectedEntry()
   {
      if(this._state == this.LIST_ACTIVE)
      {
         return this._modList.selectedEntry;
      }
      if(this._state == this.SUBLIST_ACTIVE)
      {
         return this._subList.selectedEntry;
      }
      return null;
   }
   function get isDisabled()
   {
      return this._bDisabled;
   }
   function set isDisabled(a_bDisabled)
   {
      this._bDisabled = a_bDisabled;
      this._subList.disableSelection = this._subList.disableInput = a_bDisabled;
      this._modList.disableSelection = this._modList.disableInput = a_bDisabled;
   }
   function isSublistActive()
   {
      return this._state == this.SUBLIST_ACTIVE;
   }
   function isListActive()
   {
      return this._state == this.LIST_ACTIVE;
   }
   function showList()
   {
      this.setState(this.TRANSITION_TO_LIST);
   }
   function showSublist()
   {
      if(this._modList.selectedClip == null || this._modList.selectedEntry == null)
      {
         return undefined;
      }
      this.setState(this.TRANSITION_TO_SUBLIST);
   }
   function handleInput(details, pathToFocus)
   {
      var _loc4_ = pathToFocus.shift();
      if(_loc4_ && _loc4_.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(this._bDisabled)
      {
         return false;
      }
      if(this._state == this.LIST_ACTIVE)
      {
         if(this._modList.handleInput(details,pathToFocus))
         {
            return true;
         }
      }
      else if(this._state == this.SUBLIST_ACTIVE)
      {
         if(Shared.GlobalFunc.IsKeyPressed(details,false))
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
            {
               this.showList();
               return true;
            }
         }
         if(this._subList.handleInput(details,pathToFocus))
         {
            return true;
         }
      }
      return false;
   }
   function setState(a_state)
   {
      var _loc2_;
      switch(a_state)
      {
         case this.LIST_ACTIVE:
            this.modListFader.gotoAndStop("show");
            this._modList.disableInput = false;
            this._modList.disableSelection = false;
            _loc2_ = this._modList.listState.savedIndex;
            this._modList.selectedIndex = _loc2_ <= -1 ? 0 : _loc2_;
            if(this.modListFader.getDepth() < this.subListFader.getDepth())
            {
               this.modListFader.swapDepths(this.subListFader);
            }
            this.dispatchEvent({type:"modListEnter"});
            break;
         case this.SUBLIST_ACTIVE:
            this.subListFader.gotoAndStop("show");
            this._subList.disableInput = false;
            this._subList.disableSelection = false;
            this._subList.selectedIndex = -1;
            if(this.subListFader.getDepth() < this.modListFader.getDepth())
            {
               this.subListFader.swapDepths(this.modListFader);
            }
            this.decorTitle.onPress = function()
            {
               if(!this._parent.isDisabled)
               {
                  this._parent.showList();
               }
            };
            this.dispatchEvent({type:"subListEnter"});
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
            this.dispatchEvent({type:"modListExit"});
            break;
         case this.TRANSITION_TO_LIST:
            this.decorTitle.gotoAndPlay("fadeOut");
            this.subListFader.gotoAndPlay("fadeOut");
            delete this.decorTitle.onPress;
            this._subList.disableInput = true;
            this._subList.disableSelection = true;
            this.dispatchEvent({type:"subListExit"});
            break;
         default:
            return undefined;
      }
      this._state = a_state;
   }
   function onAnimFinish(a_animID)
   {
      var _loc2_;
      switch(a_animID)
      {
         case this.ANIM_DECORTITLE_FADE_IN:
            _loc2_ = new mx.transitions.Tween(this.decorTitle,"_y",mx.transitions.easing.Strong.easeOut,this.decorTitle._y,this._modList._x + this._modList.topBorder,0.75,true);
            _loc2_.FPS = 60;
            _loc2_.onMotionFinished = mx.utils.Delegate.create(this,this.decorMotionFinishedFunc);
            _loc2_.onMotionChanged = mx.utils.Delegate.create(this,this.decorMotionUpdateFunc);
            break;
         case this.ANIM_DECORTITLE_TWEEN:
            this.subListFader.gotoAndPlay("fadeIn");
            break;
         case this.ANIM_SUBLIST_FADE_IN:
            this.setState(this.SUBLIST_ACTIVE);
            break;
         case this.ANIM_SUBLIST_FADE_OUT:
            this.modListFader.gotoAndPlay("fadeIn");
            this.hideDecorTitle(true);
            break;
         case this.ANIM_LIST_FADE_IN:
            this.setState(this.LIST_ACTIVE);
         default:
            return;
      }
   }
   function onSubListPress(a_event)
   {
   }
   function decorMotionFinishedFunc()
   {
      this.onAnimFinish(this.ANIM_DECORTITLE_TWEEN);
   }
   function decorMotionUpdateFunc()
   {
      this.decorTop._y = this._modList._y;
      this.decorTop._height = this.decorTitle._y - this.decorTop._y;
      this.decorBottom._y = this.decorTitle._y + this.decorTitle._height;
      this.decorBottom._height = this.decorBottom._y - this._modList._height;
   }
   function hideDecorTitle(a_hide)
   {
      if(a_hide)
      {
         this.decorTop._visible = true;
         this.decorTop._y = this._modList._y;
         this.decorTop._height = this._modList._height;
         this.decorTitle._visible = false;
         this.decorBottom._visible = false;
      }
      else
      {
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
