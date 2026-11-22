package flixel.group;

/** Common (non-generic) base of all groups, so collision code can walk any group. **/
class FlxGroupBase extends FlxBasic {
	public var length:Int = 0;
	/** The members, untyped (FlxTypedGroup.members is the typed view of the same array). **/
	@:size(32) public var _m:Array<FlxBasic>;
	/** How many members are groups themselves (collision checks skip the nested walk when 0). **/
	public var nestedGroups:Int = 0;

	public function new() {
		super();
		flxKind = 2;
	}

	public function memberAt(i:Int):FlxBasic {
		return null;
	}
}
