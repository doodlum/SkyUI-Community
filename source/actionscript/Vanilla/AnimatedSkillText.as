class AnimatedSkillText extends MovieClip
{
   var ThisInstance;
   var SKILLS = 18;
   var SKILL_ANGLE = 20;
   var LocationsA = [-150,-10,130,270,410,640,870,1010,1150,1290,1430];
   function AnimatedSkillText()
   {
      super();
      this.ThisInstance = this;
   }
   function InitAnimatedSkillText(aSkillTextA, aCapitalizeSkillNames)
   {
      Shared.GlobalFunc.MaintainTextFormat();
      var _loc6_ = 5;
      var _loc2_ = 0;
      var _loc3_;
      var _loc5_;
      var _loc7_;
      while(_loc2_ < aSkillTextA.length)
      {
         if(this["SkillText" + _loc2_ / _loc6_] != undefined)
         {
            _loc3_ = this["SkillText" + _loc2_ / _loc6_];
         }
         else
         {
            _loc3_ = this.attachMovie("SkillText_mc","SkillText" + _loc2_ / _loc6_,this.getNextHighestDepth());
         }
         _loc3_.LabelInstance.html = true;
         _loc5_ = aSkillTextA[_loc2_ + 1].toString();
         if(aCapitalizeSkillNames)
         {
            _loc5_ = _loc5_.toUpperCase();
         }
         _loc3_.LabelInstance.htmlText = _loc5_ + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'" + aSkillTextA[_loc2_ + 3].toString() + "\'>" + aSkillTextA[_loc2_].toString() + "</font>";
         _loc7_ = new Components.Meter(_loc3_.ShortBar);
         _loc7_.SetPercent(aSkillTextA[_loc2_ + 2]);
         if(aSkillTextA[_loc2_ + 4] > 0)
         {
            _loc3_.LegendaryIconInfoInstance._alpha = 100;
            if(aSkillTextA[_loc2_ + 4] > 1)
            {
               _loc3_.LegendaryIconInfoInstance.LegendaryCountText.SetText(aSkillTextA[_loc2_ + 4].toString(),false);
            }
            else
            {
               _loc3_.LegendaryIconInfoInstance.LegendaryCountText.SetText("");
            }
         }
         else
         {
            _loc3_.LegendaryIconInfoInstance._alpha = 0;
         }
         _loc3_._x = this.LocationsA[0];
         _loc2_ += _loc6_;
      }
   }
   function HideRing()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.SKILLS)
      {
         this.ThisInstance["SkillText" + _loc2_]._x = this.LocationsA[0];
         _loc2_ = _loc2_ + 1;
      }
   }
   function SetAngle(aAngle)
   {
      var _loc6_ = Math.floor(aAngle / this.SKILL_ANGLE);
      var _loc10_ = aAngle % this.SKILL_ANGLE / this.SKILL_ANGLE;
      var _loc2_ = 0;
      var _loc11_;
      var _loc5_;
      var _loc4_;
      var _loc8_;
      var _loc7_;
      var _loc3_;
      var _loc9_;
      while(_loc2_ < this.SKILLS)
      {
         _loc11_ = this.LocationsA.length - 2;
         _loc5_ = Math.floor(_loc11_ / 2) + 1;
         _loc4_ = _loc6_ - _loc5_ < 0 ? _loc6_ - _loc5_ + this.SKILLS : _loc6_ - _loc5_;
         _loc8_ = _loc6_ + _loc5_ >= this.SKILLS ? _loc6_ + _loc5_ - this.SKILLS : _loc6_ + _loc5_;
         _loc7_ = _loc4_ > _loc8_;
         if(!_loc7_ && (_loc2_ > _loc4_ && _loc2_ <= _loc8_) || _loc7_ && (_loc2_ > _loc4_ || _loc2_ <= _loc8_))
         {
            _loc3_ = 0;
            if(!_loc7_)
            {
               _loc3_ = _loc2_ - _loc4_;
            }
            else
            {
               _loc3_ = _loc2_ <= _loc4_ ? _loc2_ + (this.SKILLS - _loc4_) : _loc2_ - _loc4_;
            }
            _loc3_ = _loc3_ - 1;
            this.ThisInstance["SkillText" + _loc2_]._x = Shared.GlobalFunc.Lerp(this.LocationsA[_loc3_],this.LocationsA[_loc3_ + 1],1,0,_loc10_);
            _loc9_ = (_loc3_ != 4 ? _loc10_ * 100 : 100 - _loc10_ * 100) * 0.75 + 100;
            this.ThisInstance["SkillText" + _loc2_]._xscale = !(_loc3_ == 5 || _loc3_ == 4) ? 100 : _loc9_;
            this.ThisInstance["SkillText" + _loc2_]._yscale = !(_loc3_ == 5 || _loc3_ == 4) ? 100 : _loc9_;
            this.ThisInstance["SkillText" + _loc2_].ShortBar._yscale = !(_loc3_ == 5 || _loc3_ == 4) ? 100 : 100 - (_loc9_ - 100) / 2.5;
         }
         else
         {
            this.ThisInstance["SkillText" + _loc2_]._x = this.LocationsA[0];
         }
         _loc2_ = _loc2_ + 1;
      }
   }
}
