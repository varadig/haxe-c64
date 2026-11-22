package c64;

import haxe64.Types;

/** Joystick in port 2 ($DC00) or port 1 ($DC01). Bits are active-low in hardware; these helpers return true when pressed. **/
class Joy {
	public static inline function read(port:Int = 2):U8 {
		return (~(port == 2 ? Mem.peek(0xDC00) : Mem.peek(0xDC01))) & 31;
	}

	public static inline function up(port:Int = 2):Bool return (read(port) & 1) != 0;
	public static inline function down(port:Int = 2):Bool return (read(port) & 2) != 0;
	public static inline function left(port:Int = 2):Bool return (read(port) & 4) != 0;
	public static inline function right(port:Int = 2):Bool return (read(port) & 8) != 0;
	public static inline function fire(port:Int = 2):Bool return (read(port) & 16) != 0;
}
