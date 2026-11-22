package flixel.input.keyboard;

import c64.*;
import haxe64.Types;
import haxe64.Native;

/**
	Keyboard + joystick (Flixel: FlxG.keys). `FlxG.keys.pressed.LEFT`, `FlxG.keys.justPressed.SPACE`, `FlxG.keys.anyPressed([A, LEFT])`.
	The arrows (LEFT / RIGHT / UP / DOWN) are the C64 cursor keys OR the joystick in port 2; FIRE is the joystick button.
	(On the C64, LEFT is SHIFT + CRSR-RIGHT and UP is SHIFT + CRSR-DOWN; VICE maps the PC arrow keys to these.)
**/
abstract FlxKeyboard(Int) {
	public var pressed(get, never):FlxKeyList;
	public var justPressed(get, never):FlxKeyList;
	public var justReleased(get, never):FlxKeyList;

	inline function get_pressed():FlxKeyList return cast 0;

	inline function get_justPressed():FlxKeyList return cast 1;

	inline function get_justReleased():FlxKeyList return cast 2;

	/** True if any of these keys (FlxKey constants) is held. **/
	public inline function anyPressed(keys:Array<Int>):Bool return FlxKeys.any(keys, keys.length, 0);

	public inline function anyJustPressed(keys:Array<Int>):Bool return FlxKeys.any(keys, keys.length, 1);

	public inline function anyJustReleased(keys:Array<Int>):Bool return FlxKeys.any(keys, keys.length, 2);

	/** Clear the "just pressed" state, e.g. after a state switch. **/
	public inline function reset() FlxKeys.reset();
}

/** Key codes: column * 8 + row of the C64 keyboard matrix; 64+ are virtual (arrows merged with the joystick). **/
class FlxKey {
	public static inline final BACKSPACE = 0;
	public static inline final DELETE = 0;
	public static inline final ENTER = 1;
	public static inline final F7 = 3;
	public static inline final F1 = 4;
	public static inline final F3 = 5;
	public static inline final F5 = 6;
	public static inline final THREE = 8;
	public static inline final W = 9;
	public static inline final A = 10;
	public static inline final FOUR = 11;
	public static inline final Z = 12;
	public static inline final S = 13;
	public static inline final E = 14;
	public static inline final SHIFT = 15;
	public static inline final FIVE = 16;
	public static inline final R = 17;
	public static inline final D = 18;
	public static inline final SIX = 19;
	public static inline final C = 20;
	public static inline final F = 21;
	public static inline final T = 22;
	public static inline final X = 23;
	public static inline final SEVEN = 24;
	public static inline final Y = 25;
	public static inline final G = 26;
	public static inline final EIGHT = 27;
	public static inline final B = 28;
	public static inline final H = 29;
	public static inline final U = 30;
	public static inline final V = 31;
	public static inline final NINE = 32;
	public static inline final I = 33;
	public static inline final J = 34;
	public static inline final ZERO = 35;
	public static inline final M = 36;
	public static inline final K = 37;
	public static inline final O = 38;
	public static inline final N = 39;
	public static inline final PLUS = 40;
	public static inline final P = 41;
	public static inline final L = 42;
	public static inline final MINUS = 43;
	public static inline final PERIOD = 44;
	public static inline final COLON = 45;
	public static inline final AT = 46;
	public static inline final COMMA = 47;
	public static inline final ASTERISK = 49;
	public static inline final SEMICOLON = 50;
	public static inline final HOME = 51;
	public static inline final RSHIFT = 52;
	public static inline final EQUALS = 53;
	public static inline final SLASH = 55;
	public static inline final ONE = 56;
	public static inline final CONTROL = 58;
	public static inline final TWO = 59;
	public static inline final SPACE = 60;
	public static inline final COMMODORE = 61;
	public static inline final Q = 62;
	public static inline final ESCAPE = 63;
	public static inline final RUNSTOP = 63;
	public static inline final LEFT = 64;
	public static inline final RIGHT = 65;
	public static inline final UP = 66;
	public static inline final DOWN = 67;
	public static inline final FIRE = 68;
	public static inline final ANY = 69;
}

abstract FlxKeyList(Int) {
	public var BACKSPACE(get, never):Bool;

	inline function get_BACKSPACE():Bool return FlxKeys.check(0, this);

	public var DELETE(get, never):Bool;

	inline function get_DELETE():Bool return FlxKeys.check(0, this);

	public var ENTER(get, never):Bool;

	inline function get_ENTER():Bool return FlxKeys.check(1, this);

	public var F7(get, never):Bool;

	inline function get_F7():Bool return FlxKeys.check(3, this);

	public var F1(get, never):Bool;

	inline function get_F1():Bool return FlxKeys.check(4, this);

	public var F3(get, never):Bool;

	inline function get_F3():Bool return FlxKeys.check(5, this);

	public var F5(get, never):Bool;

	inline function get_F5():Bool return FlxKeys.check(6, this);

	public var THREE(get, never):Bool;

	inline function get_THREE():Bool return FlxKeys.check(8, this);

	public var W(get, never):Bool;

	inline function get_W():Bool return FlxKeys.check(9, this);

	public var A(get, never):Bool;

	inline function get_A():Bool return FlxKeys.check(10, this);

	public var FOUR(get, never):Bool;

	inline function get_FOUR():Bool return FlxKeys.check(11, this);

	public var Z(get, never):Bool;

	inline function get_Z():Bool return FlxKeys.check(12, this);

	public var S(get, never):Bool;

	inline function get_S():Bool return FlxKeys.check(13, this);

	public var E(get, never):Bool;

	inline function get_E():Bool return FlxKeys.check(14, this);

	public var SHIFT(get, never):Bool;

	inline function get_SHIFT():Bool return FlxKeys.check(15, this);

	public var FIVE(get, never):Bool;

	inline function get_FIVE():Bool return FlxKeys.check(16, this);

	public var R(get, never):Bool;

	inline function get_R():Bool return FlxKeys.check(17, this);

	public var D(get, never):Bool;

	inline function get_D():Bool return FlxKeys.check(18, this);

	public var SIX(get, never):Bool;

	inline function get_SIX():Bool return FlxKeys.check(19, this);

	public var C(get, never):Bool;

	inline function get_C():Bool return FlxKeys.check(20, this);

	public var F(get, never):Bool;

	inline function get_F():Bool return FlxKeys.check(21, this);

	public var T(get, never):Bool;

	inline function get_T():Bool return FlxKeys.check(22, this);

	public var X(get, never):Bool;

	inline function get_X():Bool return FlxKeys.check(23, this);

	public var SEVEN(get, never):Bool;

	inline function get_SEVEN():Bool return FlxKeys.check(24, this);

	public var Y(get, never):Bool;

	inline function get_Y():Bool return FlxKeys.check(25, this);

	public var G(get, never):Bool;

	inline function get_G():Bool return FlxKeys.check(26, this);

	public var EIGHT(get, never):Bool;

	inline function get_EIGHT():Bool return FlxKeys.check(27, this);

	public var B(get, never):Bool;

	inline function get_B():Bool return FlxKeys.check(28, this);

	public var H(get, never):Bool;

	inline function get_H():Bool return FlxKeys.check(29, this);

	public var U(get, never):Bool;

	inline function get_U():Bool return FlxKeys.check(30, this);

	public var V(get, never):Bool;

	inline function get_V():Bool return FlxKeys.check(31, this);

	public var NINE(get, never):Bool;

	inline function get_NINE():Bool return FlxKeys.check(32, this);

	public var I(get, never):Bool;

	inline function get_I():Bool return FlxKeys.check(33, this);

	public var J(get, never):Bool;

	inline function get_J():Bool return FlxKeys.check(34, this);

	public var ZERO(get, never):Bool;

	inline function get_ZERO():Bool return FlxKeys.check(35, this);

	public var M(get, never):Bool;

	inline function get_M():Bool return FlxKeys.check(36, this);

	public var K(get, never):Bool;

	inline function get_K():Bool return FlxKeys.check(37, this);

	public var O(get, never):Bool;

	inline function get_O():Bool return FlxKeys.check(38, this);

	public var N(get, never):Bool;

	inline function get_N():Bool return FlxKeys.check(39, this);

	public var PLUS(get, never):Bool;

	inline function get_PLUS():Bool return FlxKeys.check(40, this);

	public var P(get, never):Bool;

	inline function get_P():Bool return FlxKeys.check(41, this);

	public var L(get, never):Bool;

	inline function get_L():Bool return FlxKeys.check(42, this);

	public var MINUS(get, never):Bool;

	inline function get_MINUS():Bool return FlxKeys.check(43, this);

	public var PERIOD(get, never):Bool;

	inline function get_PERIOD():Bool return FlxKeys.check(44, this);

	public var COLON(get, never):Bool;

	inline function get_COLON():Bool return FlxKeys.check(45, this);

	public var AT(get, never):Bool;

	inline function get_AT():Bool return FlxKeys.check(46, this);

	public var COMMA(get, never):Bool;

	inline function get_COMMA():Bool return FlxKeys.check(47, this);

	public var ASTERISK(get, never):Bool;

	inline function get_ASTERISK():Bool return FlxKeys.check(49, this);

	public var SEMICOLON(get, never):Bool;

	inline function get_SEMICOLON():Bool return FlxKeys.check(50, this);

	public var HOME(get, never):Bool;

	inline function get_HOME():Bool return FlxKeys.check(51, this);

	public var RSHIFT(get, never):Bool;

	inline function get_RSHIFT():Bool return FlxKeys.check(52, this);

	public var EQUALS(get, never):Bool;

	inline function get_EQUALS():Bool return FlxKeys.check(53, this);

	public var SLASH(get, never):Bool;

	inline function get_SLASH():Bool return FlxKeys.check(55, this);

	public var ONE(get, never):Bool;

	inline function get_ONE():Bool return FlxKeys.check(56, this);

	public var CONTROL(get, never):Bool;

	inline function get_CONTROL():Bool return FlxKeys.check(58, this);

	public var TWO(get, never):Bool;

	inline function get_TWO():Bool return FlxKeys.check(59, this);

	public var SPACE(get, never):Bool;

	inline function get_SPACE():Bool return FlxKeys.check(60, this);

	public var COMMODORE(get, never):Bool;

	inline function get_COMMODORE():Bool return FlxKeys.check(61, this);

	public var Q(get, never):Bool;

	inline function get_Q():Bool return FlxKeys.check(62, this);

	public var ESCAPE(get, never):Bool;

	inline function get_ESCAPE():Bool return FlxKeys.check(63, this);

	public var RUNSTOP(get, never):Bool;

	inline function get_RUNSTOP():Bool return FlxKeys.check(63, this);

	public var LEFT(get, never):Bool;

	inline function get_LEFT():Bool return FlxKeys.check(64, this);

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT():Bool return FlxKeys.check(65, this);

	public var UP(get, never):Bool;

	inline function get_UP():Bool return FlxKeys.check(66, this);

	public var DOWN(get, never):Bool;

	inline function get_DOWN():Bool return FlxKeys.check(67, this);

	public var FIRE(get, never):Bool;

	inline function get_FIRE():Bool return FlxKeys.check(68, this);

	public var ANY(get, never):Bool;

	inline function get_ANY():Bool return FlxKeys.check(69, this);

}

/** The keyboard matrix, scanned once per frame by FlxGame. **/
class FlxKeys {
	@:size(9) static var cur:Array<U8>;
	@:size(9) static var prev:Array<U8>;
	static var BIT:Array<U8> = [1, 2, 4, 8, 16, 32, 64, 128];
	static var COLMASK:Array<U8> = [0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF, 0xBF, 0x7F];

	public static function scan() {
		for (i in 0...9) prev[i] = cur[i];
		Native.sei();
		Mem.poke(0xDC00, 0xFF);
		var joy:U8 = (~Mem.peek(0xDC00)) & 31;
		for (col in 0...8) {
			Mem.poke(0xDC00, COLMASK[col]);
			cur[col] = (~Mem.peek(0xDC01)) & 255;
		}
		Mem.poke(0xDC00, 0xFF);
		Native.cli();
		// joystick bits leak into the matrix (port 2 shares $DC00): ignore the keyboard while the stick is moved
		if (joy != 0) for (col in 0...8) cur[col] = 0;
		var shift = (cur[1] & 0x80) != 0 || (cur[6] & 0x10) != 0;
		var crsrRight = (cur[0] & 4) != 0;
		var crsrDown = (cur[0] & 0x80) != 0;
		var v = 0;
		if ((joy & 4) != 0 || (crsrRight && shift)) v |= 1; // LEFT
		if ((joy & 8) != 0 || (crsrRight && !shift)) v |= 2; // RIGHT
		if ((joy & 1) != 0 || (crsrDown && shift)) v |= 4; // UP
		if ((joy & 2) != 0 || (crsrDown && !shift)) v |= 8; // DOWN
		if ((joy & 16) != 0) v |= 16; // FIRE
		#if flixel64_autoplay
		// headless smoke test: hold RIGHT, tap SPACE / UP every 32 frames
		v = 2;
		var tap = (flixel.FlxG.frame & 31) < 6;
		for (col in 0...8) cur[col] = 0;
		if (tap) {
			v |= 4;
			cur[7] = 16;
		}
		#end
		var any = v != 0;
		for (col in 0...8) if (cur[col] != 0) any = true;
		if (any) v |= 32;
		cur[8] = v;
	}

	/** mode: 0 pressed, 1 just pressed, 2 just released. **/
	public static function check(code:Int, mode:Int):Bool {
		var i = code >> 3;
		var bit = BIT[code & 7];
		var c = (cur[i] & bit) != 0;
		var p = (prev[i] & bit) != 0;
		return mode == 0 ? c : (mode == 1 ? c && !p : !c && p);
	}

	public static function any(keys:Array<Int>, n:Int, mode:Int):Bool {
		for (i in 0...n) if (check(keys[i], mode)) return true;
		return false;
	}

	public static function reset() {
		for (i in 0...9) prev[i] = cur[i];
	}
}
