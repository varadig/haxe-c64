package flixel;

import c64.*;
import haxe64.Types;
import flixel.group.FlxGroupBase;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.FlxSound;
import flixel.util.FlxDirectionFlags;

/**
	Global helpers (Flixel: FlxG): state switching, collision, keys, sound, random, camera.

	Memory layout (VIC bank 3): screen $C000, characters $D000 (RAM under I/O: 0-63 font, 64-255 tiles),
	sprite graphics $E000-$FFBF (RAM under the KERNAL, 126 blocks of 64 bytes).
**/
class FlxG {
	public static inline final width = 320;
	public static inline final height = 200;
	public static inline final SCREEN = 0xC000;
	public static inline final CHARSET = 0xD000;
	public static inline final SPRITE_PTR = 0xC3F8;

	public static var state:FlxState = null;
	static var nextState:FlxState = null;
	public static var camera:FlxCamera = null;
	/** Frames since start (50 per second). **/
	public static var frame:U16 = 0;
	/** Bumped whenever the whole screen is redrawn (texts then redraw themselves). **/
	public static var screenEpoch:U16 = 0;

	public static var keys(get, never):FlxKeyboard;
	public static var sound(get, never):FlxSoundFront;
	public static var random(get, never):FlxRandom;

	static inline function get_keys():FlxKeyboard return cast 0;

	static inline function get_sound():FlxSoundFront return cast 0;

	static inline function get_random():FlxRandom return cast 0;

	// ------------------------------------------------------------------ setup

	public static function init() {
		// the KERNAL's 60 Hz interrupt (keyboard buffer, clock) is not needed: FlxKeys reads the keyboard itself
		Mem.poke(0xDC0D, 0x7F);
		untyped __c__("(void)*(volatile uint8_t*)0xDC0D");
		Vic.border = 0;
		Vic.background = 0;
		Vic.spriteEnable = 0;
		Mem.copyCharRom(CHARSET, 0, 512);
		Mem.poke(0xDD00, Mem.peek(0xDD00) & 0xFC); // VIC bank 3 ($C000-$FFFF)
		Vic.memorySetup = 0x04; // screen +$0000, characters +$1000
		Screen.setBase(SCREEN);
		Vic.spriteMulticolor0 = flixel.system.FlxAssets.define("flixel64_mc0", 0);
		Vic.spriteMulticolor1 = flixel.system.FlxAssets.define("flixel64_mc1", 1);
		camera = new FlxCamera();
		FlxSound.init();
		clearScreen();
	}

	public static function clearScreen() {
		Mem.fill(SCREEN, 1000, 32);
		Mem.fill(0xD800, 1000, 1);
		screenEpoch++;
	}

	public static function switchState(s:FlxState) {
		nextState = s;
	}

	/** Called by FlxGame at the start of a frame. **/
	public static function doSwitch():Bool {
		if (nextState == null) return false;
		if (state != null) state.destroy();
		state = nextState;
		nextState = null;
		Vic.spriteEnable = 0;
		Vic.control2 = Vic.control2 & 0xEF;
		camera.reset();
		clearScreen();
		state.create();
		return true;
	}

	// ------------------------------------------------------------------ sprite graphics

	@:size(16) static var cacheAddr:Array<U16>;
	@:size(16) static var cacheBlock:Array<U8>;
	static var cacheCount = 0;
	static var nextBlock:Int = 128;

	/** Copies a converted graphic into sprite memory (once) and returns its first block number. **/
	public static function uploadSprite(gfx:Array<U8>):U8 {
		var addr = Mem.addressOf(gfx);
		for (i in 0...cacheCount) if (cacheAddr[i] == addr) return cacheBlock[i];
		var n:Int = gfx[0];
		if ((gfx[1] & 2) != 0) n = n * 2;
		if (nextBlock + n > 255) {
			untyped __c__("h64_panic(\"OUT OF SPRITE MEMORY\")");
			return 128;
		}
		var b = nextBlock;
		untyped __c__("memcpy((void*)(uint16_t)(0xC000 + ({0}) * 64), ({1}) + 5, (uint16_t)({2}) * 64)", b, gfx, n);
		nextBlock += n;
		if (cacheCount < 16) {
			cacheAddr[cacheCount] = addr;
			cacheBlock[cacheCount] = b;
			cacheCount++;
		}
		return b;
	}

	/** A new sprite block with a filled w x h rectangle (hires). **/
	public static function makeBlock(w:Int, h:Int):U8 {
		var b = nextBlock;
		nextBlock++;
		var base = 0xC000 + b * 64;
		Mem.fill(base, 64, 0);
		if (w > 24) w = 24;
		if (h > 21) h = 21;
		for (row in 0...h) for (col in 0...3) {
			var bits = w - col * 8;
			var v = bits >= 8 ? 255 : (bits <= 0 ? 0 : (0xFF00 >> bits) & 255);
			Mem.poke(base + row * 3 + col, v);
		}
		return b;
	}

	// ------------------------------------------------------------------ characters (tiles)

	public static var nextChar:Int = 64;

	/** Copies `count` characters from `data` (starting at byte `offset`) into the charset; returns the first character code. **/
	public static function uploadChars(data:Array<U8>, offset:Int, count:Int):Int {
		var c = nextChar;
		if (c + count > 256) {
			untyped __c__("h64_panic(\"OUT OF CHARACTERS\")");
			return 64;
		}
		untyped __c__("h64_copy_under_io((uint16_t)(0xD000 + ({0}) * 8), ({1}) + ({2}), (uint16_t)({3}) * 8)", c, data, offset, count);
		nextChar += count;
		return c;
	}

	// ------------------------------------------------------------------ drawing (FlxGame calls these)

	@:size(8) static var hw:Array<FlxSprite>;
	static var hwCount = 0;
	@:size(16) static var texts:Array<FlxText>;
	static var textCount = 0;

	public static function beginDraw() {
		hwCount = 0;
		textCount = 0;
	}

	public static function addSprite(s:FlxSprite) {
		// only sprites inside the view get one of the 8 hardware sprites
		if (s.scrollFactor != 0) {
			var sx = s.x - s.offX - camera.scrollX;
			var sy = s.y - s.offY - camera.scrollY;
			if (sx <= -24 || sx >= 320 || sy <= -21 || sy >= camera.viewRows * 8) return;
		}
		if (hwCount < 8) {
			hw[hwCount] = s;
			hwCount++;
		}
	}

	public static function addText(t:FlxText) {
		if (textCount < 16) {
			texts[textCount] = t;
			textCount++;
		}
	}

	public static function endDraw() {
		for (i in 0...textCount) texts[i].render();
	}

	/** Writes the sprites drawn last frame into the VIC (called right after the vertical blank). **/
	public static function commitSprites() {
		var enable = 0, msb = 0, mc = 0;
		var bit = 1;
		for (i in 0...hwCount) {
			var b = bit;
			bit = bit << 1;
			var s = hw[i];
			var f:Int = s.frame;
			if (s.flipX && s.mirrorAt > 0) f += s.mirrorAt;
			Mem.poke(SPRITE_PTR + i, s.block + f);
			var sx = s.x - s.offX + 24;
			var sy = s.y - s.offY + 50;
			if (s.scrollFactor != 0) {
				sx -= camera.scrollX;
				sy -= camera.scrollY;
			}
			if (sx <= -24 || sx >= 344 || sy <= 29 || sy >= 250) continue;
			if (sx < 0) sx = 0;
			Mem.poke(0xD000 + i * 2, sx & 255);
			Mem.poke(0xD001 + i * 2, sy);
			Mem.poke(0xD027 + i, s.color);
			enable |= b;
			if (sx > 255) msb |= b;
			if (s.multicolor) mc |= b;
		}
		Vic.spriteXMsb = msb;
		Vic.spriteMulticolor = mc;
		Vic.spriteEnable = enable;
	}

	// ------------------------------------------------------------------ collision

	/** Calls `notify` for every overlapping pair (Flixel: FlxG.overlap). Groups are searched recursively. **/
	public static inline function overlap(?a:FlxBasic, ?b:FlxBasic, ?notify:Dynamic->Dynamic->Void):Bool {
		return check(a, b, notify, false);
	}

	/** Like overlap, but also pushes the objects apart (Flixel: FlxG.collide). Works with FlxTilemap too. **/
	public static inline function collide(?a:FlxBasic, ?b:FlxBasic, ?notify:Dynamic->Dynamic->Void):Bool {
		return check(a, b, notify, true);
	}

	@:noinline public static function check(a:FlxBasic, b:FlxBasic, notify:Dynamic->Dynamic->Void, sep:Bool):Bool {
		if (a == null) a = state;
		if (b == null) b = a;
		if (!a.exists || !b.exists) return false;
		var ka = a.flxKind, kb = b.flxKind;
		if (ka == 2) {
			var g:FlxGroupBase = cast a;
			var hit = false;
			for (i in 0...g.length) {
				var m = g.memberAt(i);
				if (m != null && m.exists && check(m, b, notify, sep)) hit = true;
			}
			return hit;
		}
		if (kb == 2) {
			var g:FlxGroupBase = cast b;
			var hit = false;
			for (i in 0...g.length) {
				var m = g.memberAt(i);
				if (m != null && m.exists && check(a, m, notify, sep)) hit = true;
			}
			return hit;
		}
		if (a == b) return false;
		if (ka == 3) {
			if (kb != 1) return false;
			var t:FlxTilemap = cast a;
			var o:FlxObject = cast b;
			var hit = sep ? t.collideObject(o) : t.overlapsObject(o);
			if (hit && notify != null) notify(a, b);
			return hit;
		}
		if (kb == 3) return check(b, a, notify, sep);
		if (ka != 1 || kb != 1) return false;
		var oa:FlxObject = cast a;
		var ob:FlxObject = cast b;
		if (!oa.overlaps(ob)) return false;
		if (sep && oa.solid && ob.solid) separate(oa, ob);
		if (notify != null) notify(a, b);
		return true;
	}

	@:noinline static function separate(a:FlxObject, b:FlxObject) {
		if (a.immovable && b.immovable) return;
		var ox = (a.x + a.width < b.x + b.width ? a.x + a.width : b.x + b.width) - (a.x > b.x ? a.x : b.x);
		var oy = (a.y + a.height < b.y + b.height ? a.y + a.height : b.y + b.height) - (a.y > b.y ? a.y : b.y);
		var wasOverX = a.lastX < b.lastX + b.width && b.lastX < a.lastX + a.width;
		if (!wasOverX) {
			// side hit
			var aLeft = a.x + (a.width >> 1) < b.x + (b.width >> 1);
			var d = aLeft ? -ox : ox;
			if (a.immovable) b.x -= d; else if (b.immovable) a.x += d; else {
				a.x += d >> 1;
				b.x -= d - (d >> 1);
			}
			if (!a.immovable) a.vx = 0;
			if (!b.immovable) b.vx = 0;
			a.touching = a.touching | (aLeft ? FlxDirectionFlags.RIGHT : FlxDirectionFlags.LEFT);
			b.touching = b.touching | (aLeft ? FlxDirectionFlags.LEFT : FlxDirectionFlags.RIGHT);
		} else {
			var aAbove = a.y + (a.height >> 1) < b.y + (b.height >> 1);
			var d = aAbove ? -oy : oy;
			if (a.immovable) b.y -= d; else if (b.immovable) a.y += d; else {
				a.y += d >> 1;
				b.y -= d - (d >> 1);
			}
			if (!a.immovable) {
				a.vy = 0;
				a.ry = 0;
			}
			if (!b.immovable) {
				b.vy = 0;
				b.ry = 0;
			}
			a.touching = a.touching | (aAbove ? FlxDirectionFlags.FLOOR : FlxDirectionFlags.CEILING);
			b.touching = b.touching | (aAbove ? FlxDirectionFlags.CEILING : FlxDirectionFlags.FLOOR);
		}
	}
}

abstract FlxRandom(Int) {
	/** A random integer in [min, max] (both inclusive). **/
	public inline function int(min:Int = 0, max:Int = 32767):Int {
		return min + Std.random(max - min + 1);
	}

	/** True with `chance` percent probability. **/
	public inline function bool(chance:Int = 50):Bool {
		return Std.random(100) < chance;
	}

	public inline function sign():Int {
		return Std.random(2) == 0 ? -1 : 1;
	}
}

abstract FlxSoundFront(Int) {
	/** Play a built-in SID sound effect (FlxSfx.JUMP, COIN, ...). **/
	public inline function play(sfx:Int) {
		FlxSound.play(sfx);
	}

	public var volume(never, set):Int;

	inline function set_volume(v:Int):Int {
		Sid.volume(v);
		return v;
	}
}
