class MultiColumnScrollBar extends gfx.controls.ScrollBar
{
	private var _position;
	private var _scrollDelta = 1;
	private var _trackScrollPageSize = 1;

	public function MultiColumnScrollBar()
	{
		super();
	}

	public function get trackScrollPageSize()
	{
		return this._trackScrollPageSize;
	}

	public function set trackScrollPageSize(a_val)
	{
		this._trackScrollPageSize = Math.ceil(a_val / this._scrollDelta) * this._scrollDelta;
	}

	public function get scrollDelta()
	{
		return this._scrollDelta;
	}

	public function set scrollDelta(a_val)
	{
		this._scrollDelta = a_val;
		this._trackScrollPageSize = Math.ceil(this._trackScrollPageSize / a_val) * a_val;
	}

	public function get position()
	{
		return this._position;
	}

	public function set position(a_val)
	{
		a_val -= a_val % this._scrollDelta;
		super.position = a_val;
	}

	private function scrollWheel(a_delta)
	{
		this.position -= a_delta * this._trackScrollPageSize;
	}

	private function scrollUp()
	{
		this.position -= this._scrollDelta;
	}

	private function scrollDown()
	{
		this.position += this._scrollDelta;
	}
}
