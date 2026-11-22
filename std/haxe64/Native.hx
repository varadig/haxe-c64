package haxe64;

/** Low-level helpers. For raw C use `untyped __c__("code {0}", arg)`. **/
extern class Native {
	/** Signed 16-bit integer division (Haxe `/` is a Float division). Same as `Std.int(a / b)`. **/
	@:c("((int16_t)(({0}) / ({1})))") static function div(a:Int, b:Int):Int;

	/** Busy-wait doing nothing (keeps the optimizer from removing the loop). **/
	@:c("__asm__ volatile (\"nop\")") static function nop():Void;

	/** Disable / enable interrupts. **/
	@:c("__asm__ volatile (\"sei\")") static function sei():Void;
	@:c("__asm__ volatile (\"cli\")") static function cli():Void;
}
