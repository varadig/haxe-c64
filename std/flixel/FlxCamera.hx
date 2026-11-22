package flixel;

import c64.*;
import haxe64.Types;

enum FlxCameraFollowStyle {
	/** Flip a whole screen when the target leaves it (the classic C64 way; the only style supported). **/
	SCREEN_BY_SCREEN;
	LOCKON;
	PLATFORMER;
	TOPDOWN;
}

/**
	The view (Flixel: FlxCamera). Scrolling is screen by screen: tilemaps redraw when `scroll` changes.
	`setViewRows(n)` reserves the rows below for a HUD (texts are always fixed on the screen).
**/
@:pool(1)
class FlxCamera extends FlxBasic {
	public var scrollX:Int = 0;
	public var scrollY:Int = 0;
	public var target:FlxObject = null;
	/** Height of the scrolling view in character rows (25 = full screen). **/
	public var viewRows:Int = 25;
	public var bgColor(default, set):Int = 0;
	public var borderColor(default, set):Int = 0;
	var flashT:U8 = 0;
	var shakeT:U8 = 0;

	public var scroll(get, never):FlxScroll;

	inline function get_scroll():FlxScroll return cast this;

	public function new() {
		super();
	}

	public function reset() {
		scrollX = 0;
		scrollY = 0;
		target = null;
		viewRows = 25;
		flashT = 0;
		shakeT = 0;
		Vic.background = bgColor;
		Vic.border = borderColor;
	}

	function set_bgColor(c:Int):Int {
		Vic.background = c;
		return bgColor = c;
	}

	function set_borderColor(c:Int):Int {
		Vic.border = c;
		return borderColor = c;
	}

	public inline function follow(t:FlxObject, ?style:FlxCameraFollowStyle) {
		target = t;
		updateFollow();
	}

	public inline function setViewRows(rows:Int) {
		viewRows = rows;
	}

	/** Flash the border in a color for some frames. **/
	public inline function flash(c:Int = 1, frames:Int = 6) {
		Vic.border = c;
		flashT = frames;
	}

	/** Shake the picture (hardware fine scroll) for some frames. **/
	public inline function shake(frames:Int = 12) {
		shakeT = frames;
	}

	public function updateFollow() {
		if (target == null) return;
		var cx = target.x + (target.width >> 1);
		var cy = target.y + (target.height >> 1);
		var h = viewRows * 8;
		var nx = cx < 0 ? 0 : Std.int(cx / 320) * 320;
		var ny = cy < 0 ? 0 : Std.int(cy / h) * h;
		scrollX = nx;
		scrollY = ny;
	}

	public function updateEffects() {
		if (flashT > 0) {
			flashT--;
			if (flashT == 0) Vic.border = borderColor;
		}
		if (shakeT > 0) {
			shakeT--;
			var dx = shakeT == 0 ? 0 : Std.random(4);
			var dy = shakeT == 0 ? 3 : 1 + Std.random(4);
			Vic.control2 = (Vic.control2 & 0xF8) | dx;
			Vic.control1 = (Vic.control1 & 0xF8) | dy;
		}
	}
}

abstract FlxScroll(FlxCamera) {
	public var x(get, set):Int;
	public var y(get, set):Int;

	inline function get_x() return this.scrollX;

	inline function set_x(v:Int) return this.scrollX = v;

	inline function get_y() return this.scrollY;

	inline function set_y(v:Int) return this.scrollY = v;
}
