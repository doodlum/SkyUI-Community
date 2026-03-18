class WidgetOverlay.Graph extends MovieClip
{
   var Data;
   var Height;
   var LineColor;
   var LineWidth;
   var Plot;
   var PlotHeight;
   var PlotWidth;
   var Width;
   var XAxis;
   var XGridStep;
   var XLabel;
   var XMax;
   var XMaxLabel;
   var XMaxText;
   var XMin;
   var XMinLabel;
   var XMinText;
   var YAxis;
   var YGridStep;
   var YLabel;
   var YMax;
   var YMaxLabel;
   var YMaxText;
   var YMin;
   var YMinLabel;
   var YMinText;
   var bDrawGraphBorder;
   var bDrawGraphGrid;
   var bDrawWidgetBorder;
   static var PLOT_BORDER = 20;
   function Graph()
   {
      super();
      this.XLabel = this.XAxis;
      this.XMinLabel = this.XMinText;
      this.XMinLabel.autoSize = "left";
      this.XMaxLabel = this.XMaxText;
      this.XMaxLabel.autoSize = "left";
      this.YLabel = this.YAxis;
      this.YMinLabel = this.YMinText;
      this.YMinLabel.autoSize = "left";
      this.YMaxLabel = this.YMaxText;
      this.YMaxLabel.autoSize = "left";
      this.Plot = this.createEmptyMovieClip("PlotClip",this.getNextHighestDepth());
      this.XMax = 0;
      this.XMin = 0;
      this.XGridStep = 0;
      this.YMax = 0;
      this.YMin = 0;
      this.YGridStep = 0;
      this.LineColor = 65280;
      this.LineWidth = 2;
      this.bDrawWidgetBorder = true;
      this.bDrawGraphBorder = true;
      this.bDrawGraphGrid = true;
      this.SetSize(100,100);
   }
   function SetLabels(aXLabel, aYLabel)
   {
      this.XLabel.text = aXLabel;
      this.YLabel.text = aYLabel;
   }
   function SetShowLabels(abShowXLabel, abShowYLabel)
   {
      this.XLabel._visible = abShowXLabel;
      this.XMinLabel._visible = abShowXLabel;
      this.XMaxLabel._visible = abShowXLabel;
      this.YLabel._visible = abShowYLabel;
      this.YMinLabel._visible = abShowYLabel;
      this.YMaxLabel._visible = abShowYLabel;
      this.SetSize(this.Width,this.Height);
   }
   function SetLineColor(aColor)
   {
      this.LineColor = aColor;
   }
   function SetLineWidth(aWidth)
   {
      this.LineWidth = aWidth;
   }
   function SetSize(aWidth, aHeight)
   {
      this.Width = aWidth;
      this.Height = aHeight;
      this.PositionLabels();
      var _loc2_ = !this.YLabel._visible ? 0 : WidgetOverlay.Graph.PLOT_BORDER;
      var _loc3_ = !this.XLabel._visible ? 0 : WidgetOverlay.Graph.PLOT_BORDER;
      this.Plot._x = _loc2_;
      this.Plot._y = aHeight - _loc3_;
      this.PlotHeight = aHeight - _loc3_;
      this.PlotWidth = aWidth - _loc2_;
      this.DrawBackground();
   }
   function PositionLabels()
   {
      var _loc2_ = !this.YLabel._visible ? 0 : WidgetOverlay.Graph.PLOT_BORDER;
      var _loc3_ = !this.XLabel._visible ? 0 : WidgetOverlay.Graph.PLOT_BORDER;
      this.XLabel._y = this.Height - WidgetOverlay.Graph.PLOT_BORDER;
      this.XMinLabel._y = this.XLabel._y;
      this.XMinLabel._x = _loc2_ - this.XMinLabel._width / 2;
      this.XMaxLabel._y = this.XMinLabel._y;
      this.XMaxLabel._x = this.Width - this.XMaxLabel._width / 2;
      this.YLabel._y = this.Height - WidgetOverlay.Graph.PLOT_BORDER;
      this.YMinLabel._y = this.Height - _loc3_ - this.YMinLabel._height / 2;
      this.YMinLabel._x = WidgetOverlay.Graph.PLOT_BORDER - this.YMinLabel._width;
      this.YMaxLabel._y = (- this.YMaxLabel._height) / 2;
      this.YMaxLabel._x = WidgetOverlay.Graph.PLOT_BORDER - this.YMaxLabel._width;
   }
   function SetDrawBackground(aDrawWidgetBorder, aDrawGraphBorder, aDrawGraphGrid)
   {
      this.bDrawWidgetBorder = aDrawWidgetBorder;
      this.bDrawGraphBorder = aDrawGraphBorder;
      this.bDrawGraphGrid = aDrawGraphGrid;
      this.DrawBackground();
   }
   function DrawBackground()
   {
      this.clear();
      this.lineStyle(1,0,100,false,"none");
      if(this.bDrawWidgetBorder)
      {
         this.moveTo(0,0);
         this.lineTo(0,this.Height);
         this.lineTo(this.Width,this.Height);
         this.lineTo(this.Width,0);
         this.lineTo(0,0);
      }
      if(this.bDrawGraphBorder)
      {
         this.moveTo(this.Plot._x,this.Plot._y);
         this.lineTo(this.Plot._x + this.PlotWidth,this.Plot._y);
         this.lineTo(this.Plot._x + this.PlotWidth,0);
         this.lineTo(this.Plot._x,0);
         this.lineTo(this.Plot._x,this.Plot._y);
      }
      var _loc4_;
      var _loc3_;
      var _loc5_;
      var _loc2_;
      if(this.bDrawGraphGrid)
      {
         if(this.XMax != this.XMin)
         {
            _loc4_ = this.XGridStep / (this.XMax - this.XMin) * this.PlotWidth;
            _loc3_ = _loc4_ + this.Plot._x;
            while(_loc3_ < this.Width)
            {
               this.moveTo(_loc3_,this.Plot._y);
               this.lineTo(_loc3_,0);
               _loc3_ += _loc4_;
            }
         }
         if(this.YMax != this.YMin)
         {
            _loc5_ = this.YGridStep / (this.YMax - this.YMin) * this.PlotHeight;
            _loc2_ = this.Plot._y - _loc5_;
            while(_loc2_ > 0)
            {
               this.moveTo(this.Plot._x,_loc2_);
               this.lineTo(this.Width,_loc2_);
               _loc2_ -= _loc5_;
            }
         }
      }
   }
   function SetXExtents(aMax, aMin, aStep)
   {
      this.XMax = aMax;
      this.XMaxLabel.text = String(aMax);
      this.XMin = aMin;
      this.XMinLabel.text = String(aMin);
      this.XGridStep = aStep;
      this.PositionLabels();
      this.DrawBackground();
   }
   function SetYExtents(aMax, aMin, aStep)
   {
      this.YMax = aMax;
      this.YMaxLabel.text = String(aMax);
      this.YMin = aMin;
      this.YMinLabel.text = String(aMin);
      this.YGridStep = aStep;
      this.PositionLabels();
      this.DrawBackground();
   }
   function Clear()
   {
      this.Plot.clear();
   }
   function PlotLine()
   {
      var _loc4_;
      var _loc3_;
      var _loc2_;
      if(this.XMax != this.XMin && this.YMax != this.YMin)
      {
         _loc4_ = this.PlotWidth / (this.XMax - this.XMin);
         _loc3_ = (- this.PlotHeight) / (this.YMax - this.YMin);
         if(this.Data.length > 1)
         {
            this.Plot.lineStyle(this.LineWidth,this.LineColor,100,false,"none","none","miter");
            this.Plot.moveTo(_loc4_ * (this.Data[0] - this.XMin),_loc3_ * (this.Data[1] - this.YMin));
            _loc2_ = 2;
            while(_loc2_ < this.Data.length - 1)
            {
               this.Plot.lineTo(_loc4_ * (this.Data[_loc2_] - this.XMin),_loc3_ * (this.Data[_loc2_ + 1] - this.YMin));
               _loc2_ += 2;
            }
         }
      }
   }
}
