package flixel;

/**
	Base of everything in a state (Flixel: FlxBasic). `update()` runs once per frame (50 Hz on PAL),
	there is no `elapsed`: motion is integrated by FlxObject in px/s with integer remainders.
**/
@:pool(4)
class FlxBasic {
	public var active:Bool = true;
	public var visible:Bool = true;
	public var exists:Bool = true;
	public var alive:Bool = true;
	/** 0 basic, 1 object, 2 group, 3 tilemap: a byte compare is much cheaper than Std.isOfType. **/
	public var flxKind:Int = 0;

	public function new() {}

	public function update():Void {}

	public function draw():Void {}

	public function kill():Void {
		alive = false;
		exists = false;
	}

	public function revive():Void {
		alive = true;
		exists = true;
	}

	/** Gives the object's memory back to its pool (FlxGame does this for the old state's members on switchState). **/
	public function destroy():Void {
		exists = false;
		haxe64.Pool.free(this);
	}
}
