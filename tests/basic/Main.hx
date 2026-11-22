import haxe64.Types;

enum Dir { Up; Down; Left; Right; }

@:pool(4)
class Enemy {
	public var x:Int;
	public var hp:U8;
	public function new(x:Int) { this.x = x; hp = 3; }
	public function hit():Bool { hp--; return hp == 0; }
}

class Main {
	static var table = [10, 20, 30, 40];
	static var counter:Int = 5;
	static var dir:Dir = Left;

	static function sum(n:Int):Int {
		var s = 0;
		for (i in 0...n) s += i;
		return s;
	}

	static function dirName(d:Dir):String {
		return switch d { case Up: "UP"; case Down: "DOWN"; case Left: "LEFT"; case Right: "RIGHT"; }
	}

	static function main() {
		trace(sum(10));            // 45
		var t = 0;
		for (v in table) t += v;
		trace(t);                  // 100
		trace(table.length);       // 4
		var b:U8 = 250;
		for (i in 0...10) b++;
		trace(b);                  // 4 (wraps)
		trace(Std.int(counter * 7 / 2)); // 17
		trace(dirName(dir));       // LEFT
		var e = new Enemy(12);
		var dead = false;
		while (!dead) dead = e.hit();
		trace(e.x);                // 12
		trace(haxe64.Pool.alive(e)); // true
		haxe64.Pool.free(e);
		trace(haxe64.Pool.alive(e)); // false
		var k = 0;
		while (true) { k++; if (k > 7) break; }
		trace(k);                  // 8
		var x = if (k > 3) 100 else 200;
		trace(x);                  // 100
		trace(-17 >> 1);           // -9
		trace(0x8000 >>> 15);      // 1
		var local = [3, 1, 2];
		var m = 0;
		for (i in 0...local.length) if (local[i] > m) m = local[i];
		trace(m);                  // 3
		trace(counter > 3 && counter < 10); // true
		trace("done");
	}
}
