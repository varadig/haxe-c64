package flixel;

import flixel.util.FlxDirectionFlags;

/**
	Something with a position, size and motion (Flixel: FlxObject).
	Units are integer pixels; velocity / acceleration / drag / maxVelocity are pixels per second
	(integrated at 50 Hz with exact integer remainders, so `velocity.x = 100` moves 100 px per second).
**/
class FlxObject extends FlxBasic {
	public var x:Int = 0;
	public var y:Int = 0;
	public var width:Int = 8;
	public var height:Int = 8;
	public var lastX:Int = 0;
	public var lastY:Int = 0;

	// motion (use velocity.x / acceleration.y / drag.x / maxVelocity.y)
	public var vx:Int = 0;
	public var vy:Int = 0;
	public var ax:Int = 0;
	public var ay:Int = 0;
	public var dragX:Int = 0;
	public var dragY:Int = 0;
	public var maxVX:Int = 0;
	public var maxVY:Int = 0;
	public var rx:Int = 0;
	public var ry:Int = 0;
	public var rvx:Int = 0;
	public var rvy:Int = 0;

	public var moves:Bool = true;
	public var immovable:Bool = false;
	public var solid:Bool = true;
	public var touching:FlxDirectionFlags = 0;
	public var wasTouching:FlxDirectionFlags = 0;
	/** Hardware-sprite / scrolling: 0 = fixed on screen (HUD), 1 = moves with the camera. **/
	public var scrollFactor:Int = 1;

	public var velocity(get, never):FlxVelocity;
	public var acceleration(get, never):FlxAcceleration;
	public var drag(get, never):FlxDrag;
	public var maxVelocity(get, never):FlxMaxVelocity;

	inline function get_velocity():FlxVelocity return cast this;

	inline function get_acceleration():FlxAcceleration return cast this;

	inline function get_drag():FlxDrag return cast this;

	inline function get_maxVelocity():FlxMaxVelocity return cast this;

	public function new(x:Int = 0, y:Int = 0, width:Int = 8, height:Int = 8) {
		super();
		flxKind = 1;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		lastX = x;
		lastY = y;
	}

	override public function update():Void {
		lastX = x;
		lastY = y;
		if (moves) updateMotion();
		wasTouching = touching;
		touching = FlxDirectionFlags.NONE;
	}

	function updateMotion():Void {
		// x: acceleration or drag -> velocity
		if (ax != 0) {
			rvx += ax;
			vx += untyped __c__("h64_take50(&{0})", rvx);
		} else if (dragX != 0 && vx != 0) {
			rvx += dragX;
			var d:Int = untyped __c__("h64_take50(&{0})", rvx);
			if (vx > 0) {
				vx -= d;
				if (vx < 0) vx = 0;
			} else {
				vx += d;
				if (vx > 0) vx = 0;
			}
		}
		if (maxVX != 0) {
			if (vx > maxVX) vx = maxVX else if (vx < -maxVX) vx = -maxVX;
		}
		// y
		if (ay != 0) {
			rvy += ay;
			vy += untyped __c__("h64_take50(&{0})", rvy);
		} else if (dragY != 0 && vy != 0) {
			rvy += dragY;
			var d:Int = untyped __c__("h64_take50(&{0})", rvy);
			if (vy > 0) {
				vy -= d;
				if (vy < 0) vy = 0;
			} else {
				vy += d;
				if (vy > 0) vy = 0;
			}
		}
		if (maxVY != 0) {
			if (vy > maxVY) vy = maxVY else if (vy < -maxVY) vy = -maxVY;
		}
		// safety limit (16-bit integers): 1500 px/s is 30 px per frame
		if (vx > 1500) vx = 1500 else if (vx < -1500) vx = -1500;
		if (vy > 1500) vy = 1500 else if (vy < -1500) vy = -1500;
		// velocity -> position
		rx += vx;
		x += untyped __c__("h64_take50(&{0})", rx);
		ry += vy;
		y += untyped __c__("h64_take50(&{0})", ry);
	}

	public inline function setPosition(nx:Int, ny:Int) {
		x = nx;
		y = ny;
		lastX = nx;
		lastY = ny;
	}

	public inline function setSize(w:Int, h:Int) {
		width = w;
		height = h;
	}

	public inline function isTouching(dir:Int):Bool {
		return touching.has(dir);
	}

	public inline function justTouched(dir:Int):Bool {
		return touching.has(dir) && !wasTouching.has(dir);
	}

	public function overlaps(o:FlxObject):Bool {
		return x < o.x + o.width && o.x < x + width && y < o.y + o.height && o.y < y + height;
	}

	public function overlapsPoint(px:Int, py:Int):Bool {
		return px >= x && px < x + width && py >= y && py < y + height;
	}

	/** Centre on the screen (or only on one axis). **/
	public inline function screenCenter() {
		x = (320 - width) >> 1;
		y = (200 - height) >> 1;
	}
}

abstract FlxVelocity(FlxObject) {
	public var x(get, set):Int;
	public var y(get, set):Int;

	inline function get_x() return this.vx;

	inline function set_x(v:Int) return this.vx = v;

	inline function get_y() return this.vy;

	inline function set_y(v:Int) return this.vy = v;

	public inline function set(x:Int = 0, y:Int = 0) {
		this.vx = x;
		this.vy = y;
	}
}

abstract FlxAcceleration(FlxObject) {
	public var x(get, set):Int;
	public var y(get, set):Int;

	inline function get_x() return this.ax;

	inline function set_x(v:Int) return this.ax = v;

	inline function get_y() return this.ay;

	inline function set_y(v:Int) return this.ay = v;

	public inline function set(x:Int = 0, y:Int = 0) {
		this.ax = x;
		this.ay = y;
	}
}

abstract FlxDrag(FlxObject) {
	public var x(get, set):Int;
	public var y(get, set):Int;

	inline function get_x() return this.dragX;

	inline function set_x(v:Int) return this.dragX = v;

	inline function get_y() return this.dragY;

	inline function set_y(v:Int) return this.dragY = v;

	public inline function set(x:Int = 0, y:Int = 0) {
		this.dragX = x;
		this.dragY = y;
	}
}

abstract FlxMaxVelocity(FlxObject) {
	public var x(get, set):Int;
	public var y(get, set):Int;

	inline function get_x() return this.maxVX;

	inline function set_x(v:Int) return this.maxVX = v;

	inline function get_y() return this.maxVY;

	inline function set_y(v:Int) return this.maxVY = v;

	public inline function set(x:Int = 0, y:Int = 0) {
		this.maxVX = x;
		this.maxVY = y;
	}
}
