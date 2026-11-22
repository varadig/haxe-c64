package c64;

import haxe64.Types;
import haxe64.Native;

/**
	Keyboard. `getKey()` reads the KERNAL buffer (typing); `isDown(key)` scans the
	keyboard matrix directly (held keys, for games). Key codes are column*8+row.
**/
class Keyboard {
	public static inline final DEL = 0;
	public static inline final RETURN = 1;
	public static inline final CRSR_RIGHT = 2;
	public static inline final F1 = 4;
	public static inline final CRSR_DOWN = 7;
	public static inline final W = 9;
	public static inline final A = 10;
	public static inline final Z = 12;
	public static inline final S = 13;
	public static inline final E = 14;
	public static inline final LEFT_SHIFT = 15;
	public static inline final R = 17;
	public static inline final D = 18;
	public static inline final X = 23;
	public static inline final P = 41;
	public static inline final L = 42;
	public static inline final J = 34;
	public static inline final K = 37;
	public static inline final I = 33;
	public static inline final M = 36;
	public static inline final SPACE = 60;
	public static inline final Q = 62;
	public static inline final RUN_STOP = 63;

	/** PETSCII code of the next key in the KERNAL buffer, 0 if none. **/
	public static inline function getKey():U8 {
		return untyped __c__("cbm_k_getin()");
	}

	/** True while the key is held down. **/
	public static inline function isDown(key:Int):Bool {
		Native.sei();
		Mem.poke(0xDC00, ~(1 << (key >> 3)) & 255);
		var rows:U8 = Mem.peek(0xDC01);
		Mem.poke(0xDC00, 0xFF);
		Native.cli();
		return (rows & (1 << (key & 7))) == 0;
	}
}
