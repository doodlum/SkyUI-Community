class Map.MarkerDescription extends MovieClip
{
	var DescriptionList;
	var LineItem0;
	var Title;


	/* INITIALIZATION */

	public function MarkerDescription()
	{
		super();
		this.Title = this.Title;
		this.Title.autoSize = "left";
		this.DescriptionList = new Array();
		this.DescriptionList.push(this.LineItem0);
		this.DescriptionList[0]._visible = false;
	}

	function SetDescription(aTitle, aLineItems)
	{
		this.Title.text = aTitle != undefined ? aTitle : "";
		var totalHeight = this.Title.text.length > 0 ? this.Title._height : 0;
		var i = 0;
		var item;
		var value;
		var itemString;
		while(i < aLineItems.length)
		{
			if(i >= this.DescriptionList.length)
			{
				this.DescriptionList.push(this.attachMovie("DescriptionLineItem","LineItem" + i,this.getNextHighestDepth()));
				this.DescriptionList[i]._x = this.DescriptionList[0]._x;
				this.DescriptionList[i]._y = this.DescriptionList[0]._y;
			}
			this.DescriptionList[i]._visible = true;
			item = this.DescriptionList[i].Item;
			value = this.DescriptionList[i].Value;
			itemString = aLineItems[i].Item;
			item.autoSize = "left";
			item.text = !(itemString != undefined && itemString.length > 0) ? "" : itemString + ": ";
			value.autoSize = "left";
			value.text = aLineItems[i].Value != undefined ? aLineItems[i].Value : "";
			value._x = item._x + item._width;
			totalHeight += this.DescriptionList[i]._height;
			i = i + 1;
		}
		i = aLineItems.length;
		while(i < this.DescriptionList.length)
		{
			this.DescriptionList[i]._visible = false;
			i = i + 1;
		}
		var yOffset = (- totalHeight) / 2;
		this.Title._y = yOffset;
		yOffset += this.Title.text.length > 0 ? this.Title._height : 0;
		i = 0;
		while(i < this.DescriptionList.length)
		{
			this.DescriptionList[i]._y = yOffset;
			yOffset += this.DescriptionList[i]._height;
			i = i + 1;
		}
	}

	function OnShowFinish()
	{
		gfx.io.GameDelegate.call("PlaySound",["UIMapRolloverFlyout"]);
	}
}
