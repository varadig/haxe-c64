package haxe64;

/**
	Every class gets a fixed-size object pool (default 8, change with `@:pool(N)`).
	`new Foo()` takes a slot from the pool; give it back with `Pool.free(obj)`.
**/
extern class Pool {
	/** Return the object's slot to its pool. **/
	static function free(obj:Dynamic):Void;

	/** True while the object has not been freed. **/
	static function alive(obj:Dynamic):Bool;
}
