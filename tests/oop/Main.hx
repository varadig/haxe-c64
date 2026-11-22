class Basic {
	public var alive = true;
	public var id:Int;
	public function new(id:Int = 7) { this.id = id; }
	public function update():Void { trace("basic update"); }
	public function name():String return "BASIC";
	public function kill() { alive = false; }
}

class Obj extends Basic {
	public var x:Float;
	public var vx:Float = 1.5;
	public function new(id:Int, x:Float) {
		super(id);
		this.x = x;
	}
	override public function update():Void {
		x += vx;
	}
	override public function name():String return "OBJ";
}

class Player extends Obj {
	public var hp = 3;
	override public function update():Void {
		super.update();
		hp--;
	}
	override public function name():String return "PLAYER";
}

class Coin extends Obj {}

class Main {
	static var counter = 0;

	static function onHit(a:Basic, b:Basic):Void {
		counter += a.id + b.id;
	}

	static function apply(f:(Basic, Basic) -> Void, a:Basic, b:Basic) {
		f(a, b);
	}

	static function main() {
		var list:Array<Basic> = [new Basic(1), new Obj(2, 10), new Player(3, 20.25), new Coin(4, 1)];
		for (o in list) o.update();      // basic update
		for (o in list) trace(o.name()); // BASIC OBJ PLAYER OBJ
		var p:Player = cast list[2];
		trace(p.x);                      // 21.75
		trace(p.hp);                     // 2
		trace(Std.isOfType(list[2], Obj));    // true
		trace(Std.isOfType(list[3], Player)); // false
		trace(Std.isOfType(list[3], Coin));   // true
		apply(onHit, list[0], list[3]);
		trace(counter);                  // 5
		var f:Float = 3;
		f = f * 2.5 + 1;
		trace(f);                        // 8.50
		trace(Std.int(f));               // 8
		var half = 7 / 2;
		trace(half);                     // 3.50
		trace(Math.floor(-1.5));         // -2
		trace(Math.abs(-2.25));          // 2.25
		trace(Math.sqrt(16));            // 4.00
		trace(f > 8);                    // true
		list[1].kill();
		trace(list[1].alive);            // false
		haxe64.Pool.free(list[2]);
		trace(haxe64.Pool.alive(list[2])); // false
		trace(haxe64.Pool.alive(list[3])); // true
		apply((a, b) -> counter = a.id * 10 + b.id, list[0], list[1]);
		trace(counter);                  // 12
		trace(withDefaults(1));          // 6
		trace(new Basic().id);           // 7
		var score = 120;
		trace("SCORE: " + score + " X" + 2.5);  // SCORE: 120 X2.50
		var msg = "HP ";
		msg += -3;
		trace(msg);                      // HP -3
		var frames = sumOf([4, 5, 6]);
		trace(frames);                   // 15
	}

	static function withDefaults(a:Int, b:Int = 5, ?c:Bool):Int return a + b;

	static inline function sumOf(a:Array<Int>):Int {
		return total(a, a.length);
	}

	static function total(a:Array<Int>, n:Int):Int {
		var t = 0;
		for (i in 0...n) t += a[i];
		return t;
	}
}
