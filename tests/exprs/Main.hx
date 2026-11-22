import haxe64.Types;

class Main {
	static inline function abs(v:Int):Int {
		return v < 0 ? -v : v;
	}

	static inline function clamp(v:Int, lo:Int, hi:Int):Int {
		if (v < lo) return lo;
		return v > hi ? hi : v;
	}

	static function pick(n:Int):Int {
		var r = {
			var t = n * 2;
			t + 1;
		};
		return r;
	}

	static function main() {
		var a = 3, b = 10;
		trace(abs(a - b));                     // 7
		trace(abs(a - b) < 12 && abs(b - a) < 8); // true
		trace(clamp(50, 0, 20));               // 20
		trace(pick(4));                        // 9
		var s = switch (a) { case 1: 10; case 3: 30; default: 0; };
		trace(s);                              // 30
		var art:Array<U8> = haxe64.SpriteArt.make(["#......#", "########"]);
		trace(art.length);                     // 63
		trace(art[0]);                         // 129
		trace(art[3]);                         // 255
	}
}
