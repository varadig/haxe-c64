package flixel.group;

/** Common (non-generic) base of all groups, so collision code can walk any group. **/
class FlxGroupBase extends FlxBasic {
	public var length:Int = 0;

	public function new() {
		super();
		flxKind = 2;
	}

	public function memberAt(i:Int):FlxBasic {
		return null;
	}
}
