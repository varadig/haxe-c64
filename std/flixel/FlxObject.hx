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

	// motion in internal units (1/256 px per frame / per frame²): use velocity.x / acceleration.y / drag.x / maxVelocity.y (px/s)
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

	/**
		Motion in internal units: velocity in 1/256 pixel per frame, acceleration / drag in 1/256 pixel per frame²
		(set through `velocity.x = 100` etc. in px/s - the conversion happens there, not every frame).
		Position steps are `>> 8`: a byte move on the 6502.
	**/
	inline function updateMotion():Void {
		// fields are read once into locals: every field access through `this` costs several instructions on the 6502
		var v = vx;
		var a = ax;
		if (a != 0) v += a; else if (v != 0) {
			var d = dragX;
			if (d != 0) {
				if (v > 0) {
					v -= d;
					if (v < 0) v = 0;
				} else {
					v += d;
					if (v > 0) v = 0;
				}
			}
		}
		var m = maxVX;
		if (m == 0 && a != 0) m = 7680; // 30 px per frame (1500 px/s): keeps the 16-bit math safe
		if (m != 0) {
			if (v > m) v = m else if (v < -m) v = -m;
		}
		vx = v;
		if (v != 0) {
			var t = rx + v;
			x += t >> 8;
			rx = t & 255;
		}
		v = vy;
		a = ay;
		if (a != 0) v += a; else if (v != 0) {
			var d = dragY;
			if (d != 0) {
				if (v > 0) {
					v -= d;
					if (v < 0) v = 0;
				} else {
					v += d;
					if (v > 0) v = 0;
				}
			}
		}
		m = maxVY;
		if (m == 0 && a != 0) m = 7680;
		if (m != 0) {
			if (v > m) v = m else if (v < -m) v = -m;
		}
		vy = v;
		if (v != 0) {
			var t = ry + v;
			y += t >> 8;
			ry = t & 255;
		}
	}

	public inline function setPosition(nx:Int, ny:Int) {
		x = nx;
		y = ny;
		lastX = nx;
		lastY = ny;
	}

	/** Bring back to life at a new position, without motion (Flixel: reset). **/
	public function reset(nx:Int, ny:Int):Void {
		revive();
		setPosition(nx, ny);
		vx = 0;
		vy = 0;
		rx = 0;
		ry = 0;
		touching = FlxDirectionFlags.NONE;
		wasTouching = FlxDirectionFlags.NONE;
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

	inline function get_x():Int return untyped __c__("h64_256_to_ps({0})", this.vx);

	inline function set_x(v:Int):Int {
		this.vx = untyped __c__("h64_ps_to_256({0})", v);
		return v;
	}

	inline function get_y():Int return untyped __c__("h64_256_to_ps({0})", this.vy);

	inline function set_y(v:Int):Int {
		this.vy = untyped __c__("h64_ps_to_256({0})", v);
		return v;
	}

	public inline function set(x:Int = 0, y:Int = 0) {
		this.vx = untyped __c__("h64_ps_to_256({0})", x);
		this.vy = untyped __c__("h64_ps_to_256({0})", y);
	}
}

abstract FlxAcceleration(FlxObject) {
	public var x(get, set):Int;
	public var y(get, set):Int;

	inline function get_x():Int return untyped __c__("h64_256_to_pss({0})", this.ax);

	inline function set_x(v:Int):Int {
		this.ax = untyped __c__("h64_pss_to_256({0})", v);
		return v;
	}

	inline function get_y():Int return untyped __c__("h64_256_to_pss({0})", this.ay);

	inline function set_y(v:Int):Int {
		this.ay = untyped __c__("h64_pss_to_256({0})", v);
		return v;
	}

	public inline function set(x:Int = 0, y:Int = 0) {
		this.ax = untyped __c__("h64_pss_to_256({0})", x);
		this.ay = untyped __c__("h64_pss_to_256({0})", y);
	}
}

abstract FlxDrag(FlxObject) {
	public var x(get, set):Int;
	public var y(get, set):Int;

	inline function get_x():Int return untyped __c__("h64_256_to_pss({0})", this.dragX);

	inline function set_x(v:Int):Int {
		this.dragX = untyped __c__("h64_pss_to_256({0})", v);
		return v;
	}

	inline function get_y():Int return untyped __c__("h64_256_to_pss({0})", this.dragY);

	inline function set_y(v:Int):Int {
		this.dragY = untyped __c__("h64_pss_to_256({0})", v);
		return v;
	}

	public inline function set(x:Int = 0, y:Int = 0) {
		this.dragX = untyped __c__("h64_pss_to_256({0})", x);
		this.dragY = untyped __c__("h64_pss_to_256({0})", y);
	}
}

abstract FlxMaxVelocity(FlxObject) {
	public var x(get, set):Int;
	public var y(get, set):Int;

	inline function get_x():Int return untyped __c__("h64_256_to_ps({0})", this.maxVX);

	inline function set_x(v:Int):Int {
		this.maxVX = untyped __c__("h64_ps_to_256({0})", v);
		return v;
	}

	inline function get_y():Int return untyped __c__("h64_256_to_ps({0})", this.maxVY);

	inline function set_y(v:Int):Int {
		this.maxVY = untyped __c__("h64_ps_to_256({0})", v);
		return v;
	}

	public inline function set(x:Int = 0, y:Int = 0) {
		this.maxVX = untyped __c__("h64_ps_to_256({0})", x);
		this.maxVY = untyped __c__("h64_ps_to_256({0})", y);
	}
}
