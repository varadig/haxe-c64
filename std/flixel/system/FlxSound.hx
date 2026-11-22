package flixel.system;

import c64.*;
import haxe64.Types;

/** Built-in sound effects for `FlxG.sound.play(FlxSfx.JUMP)`. **/
class FlxSfx {
	public static inline final BLIP = 0;
	public static inline final JUMP = 1;
	public static inline final COIN = 2;
	public static inline final HIT = 3;
	public static inline final EXPLOSION = 4;
	public static inline final SHOOT = 5;
	public static inline final POWERUP = 6;
	public static inline final LAND = 7;
	public static inline final SELECT = 8;
}

/** A tiny SID effect player: 3 voices, each effect = start pitch + slide per frame + length + waveform. **/
class FlxSound {
	//                                  BLIP    JUMP    COIN    HIT     EXPL    SHOOT   POWERUP LAND    SELECT
	static var FREQ:Array<Int> = [0x2000, 0x0C00, 0x3800, 0x0A00, 0x0600, 0x2800, 0x1000, 0x0500, 0x1800];
	static var SLIDE:Array<Int> = [0, 0x0180, 0x0600, -0x0100, -0x0020, -0x0500, 0x0200, -0x0080, 0x0400];
	static var LEN:Array<U8> = [4, 8, 8, 10, 24, 6, 24, 4, 6];
	static var WAVE:Array<U8> = [64, 64, 16, 128, 128, 32, 32, 16, 16];

	static var VOICE:Array<Int> = [0xD400, 0xD407, 0xD40E];
	@:size(3) static var t:Array<U8>;
	@:size(3) static var f:Array<Int>;
	@:size(3) static var df:Array<Int>;
	@:size(3) static var w:Array<U8>;
	static var nextVoice = 0;

	public static function init() {
		Sid.volume(15);
		for (v in 0...3) {
			Sid.setPulseWidth(v, 0x0800);
			Sid.setEnvelope(v, 0, 9, 4, 4);
		}
	}

	public static function play(sfx:Int) {
		if (sfx < 0 || sfx > 8) return;
		var v = nextVoice;
		nextVoice = nextVoice == 2 ? 0 : nextVoice + 1;
		t[v] = LEN[sfx];
		f[v] = FREQ[sfx];
		df[v] = SLIDE[sfx];
		w[v] = WAVE[sfx];
		var base = VOICE[v];
		Mem.poke(base, f[v] & 255);
		Mem.poke(base + 1, (f[v] >> 8) & 255);
		Mem.poke(base + 4, w[v]);
		Mem.poke(base + 4, w[v] | 1);
	}

	public static function update() {
		for (v in 0...3) {
			if (t[v] == 0) continue;
			t[v] = t[v] - 1;
			f[v] = f[v] + df[v];
			if (f[v] < 0x0100) f[v] = 0x0100;
			var base = VOICE[v];
			Mem.poke(base, f[v] & 255);
			Mem.poke(base + 1, (f[v] >> 8) & 255);
			if (t[v] == 0) Mem.poke(base + 4, w[v]);
		}
	}
}
