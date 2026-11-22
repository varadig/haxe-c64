package flixel.util;

/** Which sides of an object touch something (Flixel: `touching.has(FLOOR)`). **/
abstract FlxDirectionFlags(haxe64.Types.U8) from Int to Int {
	public static inline final NONE = 0;
	public static inline final LEFT = 1;
	public static inline final RIGHT = 2;
	public static inline final UP = 4;
	public static inline final DOWN = 8;
	public static inline final CEILING = 4;
	public static inline final FLOOR = 8;
	public static inline final WALL = 3;
	public static inline final ANY = 15;

	public inline function has(dir:Int):Bool {
		return (this & dir) != 0;
	}
}
