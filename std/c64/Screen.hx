package c64;

import haxe64.Types;

/** 40x25 text screen at $0400, color RAM at $D800. **/
class Screen {
	public static inline final WIDTH = 40;
	public static inline final HEIGHT = 25;
	public static inline final RAM = 0x0400;
	public static inline final COLOR_RAM = 0xD800;

	/** Fill the screen with spaces in the current text color. **/
	public static inline function clear() {
		untyped __c__("h64_screen_clear(32)");
	}

	/** Color used by print / printNum / clear. **/
	public static inline function setTextColor(color:Int) {
		untyped __c__("h64_text_color = (uint8_t)({0})", color);
	}

	/** Print an ASCII string at a position (converted to screen codes). **/
	public static inline function print(x:Int, y:Int, text:String) {
		untyped __c__("h64_screen_print({0}, {1}, {2})", x, y, text);
	}

	/** Print a number, zero-padded to `width` digits. **/
	public static inline function printNum(x:Int, y:Int, n:Int, width:Int = 0) {
		untyped __c__("h64_screen_print_num({0}, {1}, {2}, {3})", x, y, n, width);
	}

	/** Put a screen code with a color at a position. **/
	public static inline function put(x:Int, y:Int, code:Int, color:Int) {
		Mem.poke(RAM + y * 40 + x, code);
		Mem.poke(COLOR_RAM + y * 40 + x, color);
	}

	public static inline function get(x:Int, y:Int):U8 {
		return Mem.peek(RAM + y * 40 + x);
	}
}
